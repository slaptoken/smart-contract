// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SlapToken is ERC20, EIP712 {
    uint256 public constant MAX_SUPPLY = uint248(1000000000 ether);//totalSupply 1B

    // for DAO.
    uint256 public constant AMOUNT_DAO = MAX_SUPPLY / 100 * 20;
    address public constant ADDR_DAO = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    // for staking
    uint256 public constant AMOUNT_STAKING = MAX_SUPPLY / 100 * 20;
    address public constant ADDR_STAKING = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

    // for liquidity providers
    uint256 public constant AMOUNT_LP = MAX_SUPPLY / 100 * 10;
    address public constant ADDR_LP = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    // for airdrop
    uint256 public constant AMOUNT_AIREDROP = MAX_SUPPLY - (AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP);

    constructor(string memory _name, string memory _symbol, address _signer) ERC20(_name, _symbol) EIP712("SlapToken", "1") {
        _mint(ADDR_DAO, AMOUNT_DAO);
        _mint(ADDR_STAKING, AMOUNT_STAKING);
        _mint(ADDR_LP, AMOUNT_LP);
        _totalSupply = AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP;
        cSigner = _signer;
    }

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 amount)");

    address public immutable cSigner;

    function claim(uint256 amount, bytes memory signature) external {
        //uint256 amount = uint248(amountV);
        //uint8 v = uint8(amountV >> 248);
        uint256 total = _totalSupply + amount;
        require(total <= MAX_SUPPLY, "SlapToken: Exceed max supply");
        require(minted(msg.sender) == 0, "SlapToken: Claimed");

        bytes32 digest = _hash(msg.sender,amount);
        require(_verify(digest,signature) == cSigner, "SlapToken: Invalid signer");
        _totalSupply = total;
        _mint(msg.sender, amount);
    }


    function _hash(address receiver, uint256 amount) public view returns(bytes32){
        //return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(msg)));
        return _hashTypedDataV4(keccak256(abi.encode(MINT_CALL_HASH_TYPE, receiver, amount)));

    }

    function _verify(bytes32 digest, bytes memory signature) public pure  returns(address){
        return ECDSA.recover(digest,signature);
    }
}