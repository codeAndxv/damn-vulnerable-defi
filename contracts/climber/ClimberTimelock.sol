// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";
import "./AccessControl.sol";

/**
 * @title ClimberTimelock
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ClimberTimelock is AccessControl {
    using Address for address;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 private idTem;

    // Possible states for an operation in this timelock contract
    enum OperationState {
        Unknown,
        Scheduled,
        ReadyForExecution,
        Executed
    }

    // Operation data tracked in this contract
    struct Operation {
        uint64 readyAtTimestamp;   // timestamp at which the operation will be ready for execution
        bool known;         // whether the operation is registered in the timelock
        bool executed;      // whether the operation has been executed
    }

    // Operations are tracked by their bytes32 identifier
    mapping(bytes32 => Operation) public operations;

    uint64 public delay = 1 hours;

    constructor(
        address admin,
        address proposer
    ) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, ADMIN_ROLE);

        // deployer + self administration
        _setupRole(ADMIN_ROLE, admin);
        _setupRole(ADMIN_ROLE, address(this));

        _setupRole(PROPOSER_ROLE, proposer);
    }

    function getOperationState(bytes32 id) public view returns (OperationState) {
        Operation memory op = operations[id];

        if(op.executed) {
            return OperationState.Executed;
        } else if(op.readyAtTimestamp >= block.timestamp) {
            return OperationState.ReadyForExecution;
        } else if(op.readyAtTimestamp > 0) {
            return OperationState.Scheduled;
        } else {
            return OperationState.Unknown;
        }
    }

    function getOperationId(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(targets, values, dataElements, salt));
    }

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external onlyRole(PROPOSER_ROLE) {
        require(targets.length > 0 && targets.length < 256);
        require(targets.length == values.length);
        require(targets.length == dataElements.length);
        console.log("schedule");
        bytes32 id = getOperationId(targets, values, dataElements, salt);

        console.log(checkEqual(idTem, id));
        require(getOperationState(id) == OperationState.Unknown, "Operation already known");

        operations[id].readyAtTimestamp = uint64(block.timestamp) + delay;
        console.log(bytes32ToString(id));
        operations[id].known = true;
    }

    /** Anyone can execute what has been scheduled via `schedule` */
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external payable {
        require(targets.length > 0, "Must provide at least one target");
        require(targets.length == values.length);
        require(targets.length == dataElements.length);

        bytes32 id = getOperationId(targets, values, dataElements, salt);
        idTem = id;

        for (uint8 i = 0; i < targets.length; i++) {
            console.log("index is %s", Strings.toString(i));
            console.log("target[i] is %s", targets[i]);
            console.log("address[i] is %s", address(this));
            if(hasRole(PROPOSER_ROLE, address(this))) {
                console.log("have role");
            }else {
                console.log("have not role");
            }
            targets[i].functionCallWithValue(dataElements[i], values[i]);
            if(hasRole(PROPOSER_ROLE, address(this))) {
                console.log("have role");
            }else {
                console.log("have not role");
            }
        }
        console.log("getOperationStateInt(id) is %s", getOperationStateInt(id));
        console.log(bytes32ToString(id));
        console.log(operations[id].readyAtTimestamp);
        require(getOperationState(id) == OperationState.ReadyForExecution);
        operations[id].executed = true;
    }


    function getOperationStateInt(bytes32 id) public view returns (uint) {
        Operation memory op = operations[id];

        if(op.executed) {
            return 0;
        } else if(op.readyAtTimestamp >= block.timestamp) {
            return 1;
        } else if(op.readyAtTimestamp > 0) {
            return 2;
        } else {
            return 3;
        }
    }

    function updateDelay(uint64 newDelay) external {
        require(msg.sender == address(this), "Caller must be timelock itself");
        require(newDelay <= 14 days, "Delay must be 14 days or less");
        delay = newDelay;
    }

    receive() external payable {}

    function test() public onlyRole(ADMIN_ROLE){
        console.log(msg.sender);
        console.log("happy");
    }

    function grant1Role(bytes32 cc, address amount) public onlyRole(ADMIN_ROLE){
        console.log(msg.sender);
        console.log("happy1");
    }


    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function checkEqual(bytes32 _first, bytes32 _second) private view returns (bool){
        uint8 i = 0;
        while(i<32 && _first[i] != 0 && _second[i] != 0) {
            if(_first[i] != _second[i]) {
                return false;
            }
            i++;
        }
        return true;
    }
}
