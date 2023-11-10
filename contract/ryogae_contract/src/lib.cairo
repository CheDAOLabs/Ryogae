use starknet::ContractAddress;

#[starknet::interface]
trait IRyogae<TContractState> {
    fn query_equipment(self: @TContractState, id: u256);

    fn publish_equipment(
        ref self: TContractState,
        name: felt252,
        game: ContractAddress,
        // validity_period: u64,
        price: u256,
        coin_address: ContractAddress
    ) -> u256;

    fn buy_equipment(ref self: TContractState, id: u256,);

    fn confirm_finish(ref self: TContractState, id: u256);

    fn rollback_purchase(ref self: TContractState, id: u256);

    fn unpublish_equipment(ref self: TContractState, id: u256);
}

mod Errors {
    const EQUIPMENT_EXPIRED: felt252 = 'equipment expired';
    const INVALID_ID: felt252 = 'invalid id';
    const UNEXPECTED_OWNER: felt252 = 'unexpected owner';
    const UNEXPECTED_BUYER: felt252 = 'unexpected buyer';
    const TRANSFER_FAILED: felt252 = 'transfer failed';
    const IS_NOT_ALLOWED_TO_UNPUBLISH: felt252 = 'is not allowed to unpublish';
    const EQUIPMENT_IS_NOT_SOLD_YET: felt252 = 'equipment is not sold yet';
    const EQUIPMENT_CAN_NOT_BE_PURCHASED: felt252 = 'equipment can not be purchased';
    const NAME_CAN_NOT_BE_EMPTY: felt252 = 'name cannot be empty';
}

#[starknet::contract]
mod Ryogae {
    // Ownable to do

    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use super::{IRyogae, Errors};
    use public_contract::{
        check_owner_interface::ICheckOwnerDispatcherTrait, erc20_interface::IERC20DispatcherTrait,
        check_owner_interface, erc20_interface
    };

    #[storage]
    struct Storage {
        vault: ContractAddress,
        count: u256,
        equipments: LegacyMap<u256, Equipment>,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Equipment {
        id: u256,
        //
        publisher: ContractAddress,
        //
        // publish_time: u64,
        // validity_period: u64,
        //
        name: felt252,
        game: ContractAddress,
        //
        price: u256,
        coin_address: ContractAddress,
        //
        buyer: ContractAddress,
        status: Status,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    enum Status {
        Purchasable,
        Unpurchasable,
        Closed,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.count.write(0);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        EquipmentPublished: EquipmentPublished
    }

    #[derive(Drop, starknet::Event)]
    struct EquipmentPublished {
        #[key]
        id: u256,
        #[key]
        publisher: ContractAddress,
        #[key]
        name: felt252,
        #[key]
        game: ContractAddress,
        #[key]
        price: u256,
        #[key]
        coin_address: ContractAddress,
    }

    #[external(v0)]
    impl RyogaeImpl of IRyogae<ContractState> {
        fn publish_equipment(
            ref self: ContractState,
            name: felt252,
            game: ContractAddress,
            // validity_period: u64,
            price: u256,
            coin_address: ContractAddress
        ) -> u256 {
            // check name first
            assert(name != '', Errors::NAME_CAN_NOT_BE_EMPTY);

            let publisher: ContractAddress = starknet::get_caller_address();
            let publish_time: u64 = starknet::get_block_timestamp();

            //
            // check the address supporting ERC-20 or not
            //

            assert_owner(@self, name, game, publisher);

            let id: u256 = self.count.read() + 1;
            self.count.write(id);

            self
                .equipments
                .write(
                    id,
                    Equipment {
                        id,
                        publisher,
                        // publish_time,
                        // validity_period,
                        name,
                        game,
                        price,
                        coin_address,
                        buyer: zeroable::Zeroable::zero(),
                        status: Status::Purchasable
                    }
                );
            self.emit(EquipmentPublished { id, publisher, name, game, price, coin_address });

            id
        }

        fn buy_equipment(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = assert_id(@self, id);

            assert(
                match equipment.status {
                    Status::Purchasable => true,
                    Status::Unpurchasable => false,
                    Status::Closed => false,
                },
                Errors::EQUIPMENT_CAN_NOT_BE_PURCHASED
            );
            // assert(
            //     equipment.publish_time
            //         + equipment.validity_period > starknet::get_block_timestamp(),
            //     Errors::EQUIPMENT_EXPIRED
            // );
            assert_owner(@self, equipment.name, equipment.game, equipment.publisher);

            let buyer: ContractAddress = starknet::get_caller_address();

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer_from(buyer, self.vault.read(), equipment.price),
                Errors::TRANSFER_FAILED
            );

            equipment.buyer = buyer;
            equipment.status = Status::Unpurchasable;

            self.equipments.write(id, equipment);
        }

        fn confirm_finish(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = assert_id(@self, id);

            assert(
                match equipment.status {
                    Status::Purchasable => false,
                    Status::Unpurchasable => true,
                    Status::Closed => false,
                },
                Errors::EQUIPMENT_IS_NOT_SOLD_YET
            );

            assert_owner(@self, equipment.name, equipment.game, equipment.buyer);

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer(equipment.publisher, equipment.price),
                Errors::TRANSFER_FAILED
            );

            equipment.status = Status::Closed;

            self.equipments.write(id, equipment);
        }

        fn rollback_purchase(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = assert_id(@self, id);

            assert(
                match equipment.status {
                    Status::Purchasable => false,
                    Status::Unpurchasable => true,
                    Status::Closed => false,
                },
                Errors::EQUIPMENT_IS_NOT_SOLD_YET
            );

            let buyer: ContractAddress = starknet::get_caller_address();
            assert(equipment.buyer == buyer, Errors::UNEXPECTED_BUYER);
            assert_not_owner(@self, equipment.name, equipment.game, buyer);

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer(equipment.publisher, equipment.price),
                Errors::TRANSFER_FAILED
            );

            equipment.status = Status::Purchasable;
            equipment.buyer = zeroable::Zeroable::zero();

            self.equipments.write(id, equipment);
        }

        fn unpublish_equipment(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = assert_id(@self, id);

            assert(
                match equipment.status {
                    Status::Purchasable => true,
                    Status::Unpurchasable => false,
                    Status::Closed => false,
                },
                Errors::IS_NOT_ALLOWED_TO_UNPUBLISH
            );

            assert(equipment.publisher == starknet::get_caller_address(), Errors::UNEXPECTED_OWNER);

            equipment.status = Status::Closed;
            self.equipments.write(id, equipment);
        }

        fn query_equipment(self: @ContractState, id: u256) {
            let equipment: Equipment = assert_id(self, id);
        }
    }

    fn assert_id(self: @ContractState, id: u256) -> Equipment {
        assert(id <= self.count.read(), Errors::INVALID_ID);
        self.equipments.read(id)
    }

    fn assert_owner(
        self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
    ) {
        assert(check_owner(self, name, game, owner), Errors::UNEXPECTED_OWNER);
    }

    fn assert_not_owner(
        self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
    ) {
        assert(!check_owner(self, name, game, owner), Errors::UNEXPECTED_OWNER);
    }

    fn check_owner(
        self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
    ) -> bool {
        check_owner_interface::ICheckOwnerDispatcher { contract_address: game }
            .check_owner(name, owner)
    }
}
