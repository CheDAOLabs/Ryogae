mod interface;

use starknet::ContractAddress;
use Ryogae::Equipment;

mod errors;

#[starknet::contract]
mod Ryogae {
    // Ownable to do

    use ryogae_contract::interface::IRyogae;
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, SyscallResultTrait};
    use super::errors;
    use public_contract::{
        check_owner_interface::ICheckOwnerDispatcherTrait, erc20_interface::IERC20DispatcherTrait,
        check_owner_interface, erc20_interface
    };

    #[storage]
    struct Storage {
        count: u256,
        vault: ContractAddress,
        equipments: LegacyMap<u256, Equipment>,
        game_checker: LegacyMap<ContractAddress, ContractAddress>,
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

    #[generate_trait]
    impl StatusTraitImpl of StatusTrait {
        fn is_puchasable(self: Status) -> bool {
            match self {
                Status::Purchasable => true,
                Status::Unpurchasable => false,
                Status::Closed => false,
            }
        }

        fn is_unpuchasable(self: Status) -> bool {
            match self {
                Status::Purchasable => false,
                Status::Unpurchasable => true,
                Status::Closed => false,
            }
        }

        fn is_close(self: Status) -> bool {
            match self {
                Status::Purchasable => false,
                Status::Unpurchasable => false,
                Status::Closed => true,
            }
        }
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
            assert(name != '', errors::NAME_CAN_NOT_BE_EMPTY);

            let publisher: ContractAddress = starknet::get_caller_address();
            let publish_time: u64 = starknet::get_block_timestamp();

            //
            // check the address supporting ERC-20 or not
            //

            self.assert_owner(name, game, publisher);

            let id: u256 = self.count.read() + 1;
            self.count.write(id);

            self
                .equipments
                .write(
                    id,
                    Equipment {
                        id: id,
                        publisher: publisher,
                        // publish_time,
                        // validity_period,
                        name: name,
                        game: game,
                        price: price,
                        coin_address: coin_address,
                        buyer: zeroable::Zeroable::zero(),
                        status: Status::Purchasable
                    }
                );
            self.emit(EquipmentPublished { id, publisher, name, game, price, coin_address });

            id
        }

        fn buy_equipment(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = self.get_equipment(id);

            assert(equipment.status.is_puchasable(), errors::EQUIPMENT_CAN_NOT_BE_PURCHASED);
            //
            // assert(
            //     equipment.publish_time
            //         + equipment.validity_period > starknet::get_block_timestamp(),
            //     errors::EQUIPMENT_EXPIRED
            // );
            //
            self.assert_owner(equipment.name, equipment.game, equipment.publisher);

            let buyer: ContractAddress = starknet::get_caller_address();

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer_from(buyer, self.vault.read(), equipment.price),
                errors::TRANSFER_FAILED
            );

            equipment.buyer = buyer;
            equipment.status = Status::Unpurchasable;

            self.equipments.write(id, equipment);
        }

        fn confirm_finish(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = self.get_equipment(id);

            assert(equipment.status.is_unpuchasable(), errors::EQUIPMENT_IS_NOT_SOLD_YET);

            self.assert_owner(equipment.name, equipment.game, equipment.buyer);

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer(equipment.publisher, equipment.price),
                errors::TRANSFER_FAILED
            );

            equipment.status = Status::Closed;

            self.equipments.write(id, equipment);
        }

        fn rollback_purchase(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = self.get_equipment(id);

            assert(equipment.status.is_unpuchasable(), errors::EQUIPMENT_IS_NOT_SOLD_YET);

            let buyer: ContractAddress = starknet::get_caller_address();
            assert(equipment.buyer == buyer, errors::UNEXPECTED_BUYER);
            self.assert_not_owner(equipment.name, equipment.game, buyer);

            assert(
                erc20_interface::IERC20Dispatcher { contract_address: equipment.coin_address }
                    .transfer(equipment.publisher, equipment.price),
                errors::TRANSFER_FAILED
            );

            equipment.status = Status::Purchasable;
            equipment.buyer = zeroable::Zeroable::zero();

            self.equipments.write(id, equipment);
        }

        fn unpublish_equipment(ref self: ContractState, id: u256) {
            let mut equipment: Equipment = self.get_equipment(id);

            assert(equipment.status.is_puchasable(), errors::IS_NOT_ALLOWED_TO_UNPUBLISH);

            assert(equipment.publisher == starknet::get_caller_address(), errors::UNEXPECTED_OWNER);

            equipment.status = Status::Closed;
            self.equipments.write(id, equipment);
        }

        fn query_equipment(self: @ContractState, id: u256) -> Equipment {
            self.get_equipment(id)
        }


        fn update_game_checker(
            ref self: ContractState, game: ContractAddress, game_checker: ContractAddress
        ) {
            self.game_checker.write(game, game_checker);
        }


        fn get_game_checker(self: @ContractState, game: ContractAddress) -> ContractAddress {
            self.game_checker.read(game)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn get_equipment(self: @ContractState, id: u256) -> Equipment {
            assert(id <= self.count.read(), errors::INVALID_ID);
            self.equipments.read(id)
        }

        fn assert_owner(
            self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
        ) {
            assert(self.check_owner(name, game, owner), errors::UNEXPECTED_OWNER);
        }

        fn assert_not_owner(
            self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
        ) {
            assert(!self.check_owner(name, game, owner), errors::UNEXPECTED_OWNER);
        }

        fn assert_checker(self: @ContractState, game: ContractAddress) -> ContractAddress {
            let game_checker: ContractAddress = self.game_checker.read(game);
            assert(game_checker != zeroable::Zeroable::zero(), errors::NO_GAME_CHECKER);
            game_checker
        }

        fn check_owner(
            self: @ContractState, name: felt252, game: ContractAddress, owner: ContractAddress
        ) -> bool {
            let game_checker: ContractAddress = self.assert_checker(game);

            // the better way to do this is using LibraryDispatcher
            // but counldn't define it through dynamic felt252 to get ClashHash
            check_owner_interface::ICheckOwnerDispatcher { contract_address: game_checker }
                .check_owner(name, owner)
        }
    }

    // starknet::get_contract_address()
    #[external(v0)]
    fn update_vault(ref self: ContractState, vault: ContractAddress) {
        assert(self.count.read() == 0, '');
        self.vault.write(vault);
    }
}
