use starknet::ContractAddress;
use super::Equipment;

#[starknet::interface]
trait IRyogae<TContractState> {
    fn query_equipment(self: @TContractState, id: u256) -> Equipment;

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

    fn update_game_checker(
        ref self: TContractState, game: ContractAddress, game_checker: ContractAddress
    );

    fn get_game_checker(self: @TContractState, game: ContractAddress) -> ContractAddress;
}
