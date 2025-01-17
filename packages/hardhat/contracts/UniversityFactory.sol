// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import './University.sol';

interface IUniversity {
    function donate(uint _id, address _erc20, uint _amount) external payable;
    function createDonate(uint _startBlockNumber, uint _endBlockNumber) external;
    function withdrawDonate(uint _id, address _erc20) external;
}

// 大学工厂创建大学
contract UniversityFactory is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Parameters {
        address owner;
        string name;
        string introduce;
    }

    // id => 大学地址
    mapping(uint => address) public idToUniversity;
    mapping(address => uint) public addrToUniversity;
    Parameters[] public allUniversity;

    Parameters public parameters;

    constructor() public { }

    function createUniversity(
        string calldata _name,
        string calldata _introduce
    )
        external
    {
        allUniversity.push(Parameters({
            owner: msg.sender,
            name: _name,
            introduce: _introduce
        }));

        address addr = deploy(_name, _introduce);
        idToUniversity[allUniversity.length - 1] = addr;
        addrToUniversity[addr] = allUniversity.length - 1;
    }

    function universityLength() external view returns (uint) {
        return allUniversity.length;
    }

    function createDonate(address uni, uint _startBlockNumber, uint _endBlockNumber) external {
        IUniversity(uni).createDonate(_startBlockNumber, _endBlockNumber);
    }

    function donate(address uni, uint _id, address _erc20, uint _amount) external payable {
        IUniversity(uni).donate{value: msg.value}(_id, _erc20, _amount);
    }

    function withdrawDonate(address uni, uint _id, address _erc20) external {
        IUniversity(uni).withdrawDonate(_id, _erc20);
    }

    function deploy(
        string calldata _name,
        string calldata _introduce
    ) internal returns (address university) {
        parameters = Parameters({ owner: address(this), name: _name, introduce: _introduce});
        university = address(new University{salt: keccak256(abi.encode(address(this), _name, _introduce))}());
        delete parameters;
    }
}
