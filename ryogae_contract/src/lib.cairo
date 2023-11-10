mod check_owner_interface;
mod erc20_interface;

use starknet::ContractAddress;

#[starknet::interface]
trait IRyogae<TContractState> {
    // fn query_equipment(
    //     self:@TContractState,
    //     id_or_something: felt252
    // );

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

    fn rollback_purchase_for_buyer(ref self: TContractState, id: u256);

    fn unpublish_equipment(ref self: TContractState, id: u256);
}

mod Errors {
    const EQUIPMENT_EXPIRED: felt252 = 'equipment expired';
    const INVALID_ID: felt252 = 'invalid id';
    const UNEXPECTED_OWNER: felt252 = 'unexpected owner';
}

#[starknet::contract]
mod Ryogae {
    // Ownable to do
    // todo events, though it is not necessary

    use starknet::ContractAddress;
    use super::{
        check_owner_interface::ICheckOwnerDispatcherTrait, erc20_interface::IERC20DispatcherTrait,
        IRyogae, check_owner_interface, erc20_interface, Errors
    };

    #[storage]
    struct Storage {
        vault: ContractAddress,
        count: u256,
        equipments: LegacyMap<u256, Equipment>,
    }

    #[derive(Copy, Drop, Serde)]
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

    #[derive(Copy, Drop, Serde)]
    enum Status {
        Purchasable,
        Unpurchasable,
        Closed,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.count.write(0);
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
            assert(name != '', 'name cannot be empty');

            let publisher: ContractAddress = starknet::get_caller_address();
            let publish_time: u64 = starknet::get_block_timestamp();

            //
            // check the address supporting ERC-20 or not
            //

            assert(check_owner(@self, name, game, publisher), 'not the owner');

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

            id
        }

        fn buy_equipment(ref self: ContractState, id: u256) {
            assert_id(@self, id);

            let mut equipment: Equipment = self.equipments.read(id);
            assert(
                match equipment.status {
                    Status::Purchasable => true,
                    Status::Unpurchasable => false,
                    Status::Closed => false,
                },
                'equipment looks closed already'
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
                'transfer failed'
            );

            equipment.buyer = buyer;
            equipment.status = Status::Unpurchasable;

            self.equipments.write(id, equipment);
        }

        fn confirm_finish(ref self: ContractState, id: u256) {
            assert_id(@self, id);

            let mut equipment: Equipment = self.equipments.read(id);
            assert(
                match equipment.status {
                    Status::Purchasable => false,
                    Status::Unpurchasable => true,
                    Status::Closed => false,
                },
                'equipment is not sold yet'
            );

            assert_owner(@self, equipment.name, equipment.game, equipment.buyer);

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer(equipment.publisher, equipment.price),
                'transfer failed'
            );

            equipment.status = Status::Closed;

            self.equipments.write(id, equipment);
        }

        fn rollback_purchase_for_buyer(ref self: ContractState, id: u256) {}

        fn unpublish_equipment(ref self: ContractState, id: u256) {}
    }

    fn assert_id(self: @ContractState, id: u256) {
        assert(id <= self.count.read(), Errors::INVALID_ID);
    }

    fn assert_owner(
        self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
    ) {
        assert(check_owner(self, name, game, owner), Errors::UNEXPECTED_OWNER);
    }

    fn check_owner(
        self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
    ) -> bool {
        check_owner_interface::ICheckOwnerDispatcher { contract_address: game }.check_owner(name, owner)
    }
}
