use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use snforge_std::PrintTrait;
use starknet::ContractAddress;
use starknet::Felt252TryIntoContractAddress;

use snforge_std::{declare, ContractClassTrait, start_prank};

use contract1::voting_contract1::Votingcode;
//InterfaceのTraitDispatcherとDispatcherについて
//storageではなく1つ上のmodファイル名直下
use contract1::voting_contract1::VoteTraitDispatcher;
use contract1::voting_contract1::VoteTraitDispatcherTrait;


#[test]
fn prank_the_constructor() {
    let contract = declare('Votingcode');
    let mut constructor_arguments = ArrayTrait::new();

    constructor_arguments.append(0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973);

    let snap_args = @constructor_arguments;

    let contract_address = contract.precalculate_address(snap_args);

    start_prank(contract_address, 123.try_into().unwrap());

    let contract_address = contract.deploy(snap_args).unwrap();

    let dispatcher = VoteTraitDispatcher { contract_address };
    dispatcher.voter_register();

    dispatcher.vote(1);
    let (a, b, c, d) = dispatcher.get_vote_status();
    a.print();
    b.print();
    c.print();
    d.print();
}
