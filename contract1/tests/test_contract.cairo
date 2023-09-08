use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use starknet::ContractAddress;
use starknet::Felt252TryIntoContractAddress;

use snforge_std::{declare, ContractClassTrait, start_prank};

use votecontract::VoteTraitDispatcher;
use votecontract::VoteTraitDispatcherTrait;


#[test]
fn prank_the_constructor() {
    let contract = declare('Votingcode');
    let mut constructor_arguments = ArrayTrait::new();

    constructor_arguments.append(0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973);
    constructor_arguments.append(0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855);
    constructor_arguments.append(0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da);

    let snap_args = @constructor_arguments;

    let contract_address = contract.precalculate_address(snap_args);

    start_prank(contract_address, 123.try_into().unwrap());

    contract.deploy(snap_args).unwrap();
}
