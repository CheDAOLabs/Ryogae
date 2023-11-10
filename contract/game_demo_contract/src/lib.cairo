#[starknet::contract]
mod Game {
    use public_contract::check_owner_interface;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        own: LegacyMap<felt252, ContractAddress>,
    }

    #[external(v0)]
    impl CheckOwnerImpl of check_owner_interface::ICheckOwner<ContractState> {
        fn check_owner(self: @ContractState, name: felt252, owner: ContractAddress) -> bool {
            self.own.read(name) == owner
        }
    }

    #[external(v0)]
    fn update_owner(ref self: ContractState, name: felt252, owner: ContractAddress) {
        self.own.write(name, owner);
    }
}
