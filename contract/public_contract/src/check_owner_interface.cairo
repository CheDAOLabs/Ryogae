use starknet::ContractAddress;

#[starknet::interface]
trait ICheckOwner<TState> {
    fn check_owner(self: @TState, name: felt252, owner: ContractAddress) -> bool;
}
