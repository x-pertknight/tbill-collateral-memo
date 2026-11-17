// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0 ^0.8.1 ^0.8.2 ^0.8.20 ^0.8.28;

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// dependencies/chainlink-2.11.1/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}

// protocol/token/src/interfaces/IAccountingPausable.sol

/**
 * @title IAccountingPausable
 * @notice Interface for pausable accounting functionality
 * @dev Defines the interface for pausing and unpausing minting and burning operations independently from transfers
 */
interface IAccountingPausable {
    /**
     * @dev Pauses accounting operations (minting and burning)
     * @notice Can only be called by authorized addresses (defined in implementation)
     */
    function accountingPause() external;

    /**
     * @dev Unpauses accounting operations
     * @notice Can only be called by authorized addresses (defined in implementation)
     */
    function accountingUnpause() external;

    /**
     * @dev Returns whether accounting is currently paused
     * @return True if accounting is paused, false otherwise
     */
    function isAccountingPaused() external view returns (bool);

    /**
     * @dev Emitted when accounting is paused by `pauser`
     */
    event AccountingPaused(address indexed pauser);

    /**
     * @dev Emitted when accounting is unpaused by `unpauser`
     */
    event AccountingUnpaused(address indexed unpauser);

    /**
     * @dev Error thrown when attempting to perform accounting operations while paused
     */
    error AccountingIsPaused();

    /**
     * @dev Error thrown when attempting to unpause accounting when it's not paused
     */
    error AccountingIsNotPaused();
}

// protocol/allowlist/src/interfaces/IAllowlistAddressPermissions.sol

/**
 * @title IAllowlistAddressPermissions
 * @notice Core interface for address permissions and entity ID lookups
 * @dev This interface provides the essential allowlist functions needed for
 * checking address permissions and entity mappings
 */
interface IAllowlistAddressPermissions {
    /**
     * @notice Gets the entityId for the provided address
     * @param addr The address to get the entityId for
     */
    function addressEntityIds(address addr) external view returns (uint256);

    /**
     * @notice Checks whether an address is allowed to use a private instrument
     * @param addr The address to check permissions for
     * @param instrument The private instrument symbol to check permissions for
     */
    function isAddressAllowedForPrivateInstrument(address addr, string calldata instrument) external view returns (bool);

    /**
     * @dev Checks if an address is allowed to interact with public instrument
     * @param addr The address to check
     * @return True if the address is allowed, false otherwise
     */
    function isAddressAllowedForPublicInstrument(address addr) external view returns (bool);
}
// protocol/token/src/interfaces/IAllowlistable.sol

/**
 * @title IAllowlistable
 * @notice Interface for allowlist functionality
 * @dev Defines the interface for checking if addresses have permission to interact with the token
 */
interface IAllowlistable {
    /**
     * @dev Returns the current allowlist contract
     * @return The allowlist contract address
     */
    function allowlist() external view returns (address);

    /**
     * @dev Returns whether the instrument is public or private
     * @return True if the instrument is public, false if private
     */
    function isPublicInstrument() external view returns (bool);

    /**
     * @dev Checks if an address is allowed based on instrument type
     * @param addr The address to check
     * @return True if the address is allowed, false otherwise
     * @notice Automatically uses public or private permission check based on isPublicInstrument().
     *         Uses V3 compat functions on allowlist for smooth AllowlistV3→V4 upgrade.
     */
    function isAllowed(address addr) external view returns (bool);

    /**
     * @dev Emitted when the allowlist is updated
     */
    event AllowlistUpdated(address indexed oldAllowlist, address indexed newAllowlist);

    /**
     * @dev Emitted when the instrument type (public/private) is updated
     */
    event IsPublicInstrumentUpdated(bool oldIsPublicInstrument, bool newIsPublicInstrument);

    /**
     * @dev Error thrown when an address doesn't have sufficient permissions
     */
    error InsufficientPermissions();

    error ZeroAddressNotAllowed();

    error AlreadySet();
}

// protocol/token/src/interfaces/IBridgeable.sol

/**
 * @title IBridgeable
 * @notice Interface for cross-chain bridging functionality
 * @dev Defines the interface for burning tokens on one chain and minting on another
 */
interface IBridgeable {
    /**
     * @dev Returns whether a chain ID is supported for bridging
     * @param chainId The chain ID to check
     * @return True if the chain ID is supported, false otherwise
     */
    function isChainIdSupported(uint256 chainId) external view returns (bool);

    /**
     * @dev Sets support status for a specific chain ID
     * @param chainId The chain ID to update
     * @param supported Whether the chain ID should be supported
     */
    function setChainIdSupport(uint256 chainId, bool supported) external;

    /**
     * @notice Burns tokens from the caller to bridge to another chain
     * @dev Reverts if chainId is not supported.
     * @dev If destination address on chainId isn't on allowlist on the other chain, tokens burn to book entry.
     * @dev Use chainId 0 to burn tokens to Superstate book entry.
     * @param amount Amount of tokens to burn
     * @param ethDestinationAddress ETH address to send to on another chain
     * @param otherDestinationAddress Non-EVM addresses to send to on another chain
     * @param chainId Numerical identifier of destination chain to send tokens to
     */
    function bridge(
        uint256 amount,
        address ethDestinationAddress,
        string memory otherDestinationAddress,
        uint256 chainId
    ) external;

    /**
     * @dev Burns tokens from the caller to bridge to Superstate book entry
     * @param amount Amount of tokens to burn
     */
    function bridgeToBookEntry(uint256 amount) external;

    /// @notice Emitted when a chain ID's support status is updated
    event SetChainIdSupport(uint256 indexed chainId, bool oldSupported, bool newSupported);

    /// @dev Event emitted when the user wants to bridge their tokens to another chain or book entry
    event Bridge(
        address caller,
        address indexed src,
        uint256 amount,
        address indexed ethDestinationAddress,
        string otherDestinationAddress,
        uint256 chainId
    );

    /**
     * @dev Error thrown when destination chain is not supported
     */
    error BridgeChainIdDestinationNotSupported();

    /**
     * @dev Error thrown when both ETH and non-ETH destination addresses are provided
     */
    error TwoDestinationsInvalid();

    /**
     * @dev Error thrown when zero tokens are provided for bridging
     */
    error ZeroSuperstateTokensOutBridgeable();

    /**
     * @dev Error thrown when destination is set for bridge to book entry
     */
    error OnchainDestinationSetForBridgeToBookEntry();

    /**
     * @dev Error thrown for invalid function arguments
     */
    error BadArgsBridgeable();
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/token/ERC20/IERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// protocol/token/src/interfaces/IOracleConsumable.sol

/**
 * @title IOracleConsumable
 * @notice Interface for contracts that consume Chainlink oracle data
 */
interface IOracleConsumable {
    /**
     * @notice Returns the oracle address
     * @return The address of the oracle
     */
    function superstateOracle() external view returns (address);

    /**
     * @notice Returns the maximum oracle delay
     * @return The maximum acceptable delay in seconds
     */
    function maximumOracleDelay() external view returns (uint256);

    /**
     * @notice Gets the Chainlink price data
     * @return _isBadData True if the data is stale or below threshold
     * @return _updatedAt The timestamp of the last update
     * @return _price The price from the oracle
     */
    function getChainlinkPrice() external view returns (bool _isBadData, uint256 _updatedAt, uint256 _price);

    /**
     * @notice Sets the maximum oracle delay
     * @param _newMaxOracleDelay The new maximum delay in seconds
     */
    function setMaximumOracleDelay(uint256 _newMaxOracleDelay) external;

    /**
     * @notice Sets the oracle address
     * @param _newOracle The new oracle address
     */
    function setOracle(address _newOracle) external;

    /// @dev Event emitted when the address for the pricing oracle changes
    event SetOracle(address oldOracle, address newOracle);

    /// @dev Emitted when the max oracle delay is set
    event SetMaximumOracleDelay(uint256 oldMaxOracleDelay, uint256 newMaxOracleDelay);

    /**
     * @dev Error thrown when oracle data is bad (stale or below threshold)
     */
    error BadChainlinkData();

    /**
     * @dev Error thrown when onchain subscriptions are disabled
     */
    error OnchainSubscriptionsDisabled();

    /**
     * @dev Error thrown when function arguments are invalid
     */
    error BadArgsOracleConsumable();
}

// protocol/token/src/interfaces/IPermittable.sol

/**
 * @title IPermittable
 * @notice Interface for the Permittable contract implementing EIP-712 compliant permit functionality
 * @dev Defines functions for approving token spending through signatures (EIP-2612)
 */
interface IPermittable {
    /**
     * @dev Error thrown when signature has expired
     */
    error SignatureExpired();

    /**
     * @dev Error thrown when S value in signature is invalid
     */
    error InvalidSignatureS();

    /**
     * @dev Error thrown when signature verification fails
     */
    error BadSignatory();

    /**
     * @dev Returns the current nonce for an address
     * @param owner The address to get the nonce for
     * @return The current nonce
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Sets approval amount for a spender via signature from signatory
     * @param owner The address that signed the signature
     * @param spender The address to authorize (or rescind authorization from)
     * @param value Amount that `owner` is approving for `spender`
     * @param deadline Expiration time for the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    /**
     * @dev Returns the domain separator used in the encoding of the signature for permit
     * @return bytes32 The domain separator
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// protocol/token/src/interfaces/IRedeemable.sol

/**
 * @title IRedeemable
 * @notice Interface for tokens that can be redeemed through a dedicated redemption contract
 */
interface IRedeemable {
    /**
     * @notice Returns the current redemption contract address
     * @return The address of the redemption contract
     */
    function getRedemptionContract() external view returns (address);

    /**
     * @notice Sets redemption contract address
     * @dev Used for convenience for devs
     * @dev Set to address(0) if no such contract exists for the token
     * @param _newRedemptionContract New contract address
     */
    function setRedemptionContract(address _newRedemptionContract) external;

    /**
     * @notice Burns tokens from the caller's address for offchain redemption
     * @param amount Amount of tokens to burn
     */
    function offchainRedeem(uint256 amount) external;

    /// @dev Event emitted when the owner changes the redemption contract address
    event SetRedemptionContract(address oldRedemptionContract, address newRedemptionContract);

    /// @dev Event emitted when the users wants to redeem their shares with an offchain payout
    event OffchainRedeem(address indexed burner, address indexed src, uint256 amount);

    /**
     * @dev Error thrown when function arguments are invalid
     */
    error BadArgsRedeemable();
}

// protocol/token/src/interfaces/ISubscribable.sol

/**
 * @title ISubscribable
 * @notice Interface for contracts that allow token minting through stablecoin deposits
 * @custom:version 1.2.0
 */
interface ISubscribable {
    struct StablecoinConfig {
        address sweepDestination;
        uint96 fee;
    }

    /**
     * @notice Returns the configuration for a stablecoin
     * @param stablecoin The stablecoin address
     * @return The stablecoin configuration
     */
    function supportedStablecoins(address stablecoin) external view returns (StablecoinConfig memory);

    /**
     * @notice Sets the configuration for a stablecoin
     * @param stablecoin The stablecoin address
     * @param newSweepDestination The address to send stablecoins to
     * @param newFee The fee in basis points (max 10 = 0.1%)
     */
    function setStablecoinConfig(address stablecoin, address newSweepDestination, uint96 newFee) external;

    /**
     * @notice Calculates the fee for a subscription
     * @param amount The amount to calculate fee on
     * @param subscriptionFee The fee percentage in basis points
     * @return The fee amount
     */
    function calculateFee(uint256 amount, uint256 subscriptionFee) external pure returns (uint256);

    /**
     * @notice Calculates the amount of tokens to mint for a subscription
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     * @return superstateTokenOutAmount The amount of tokens to mint
     * @return stablecoinInAmountAfterFee The amount of stablecoin after fee
     * @return feeOnStablecoinInAmount The fee amount
     */
    function calculateSuperstateTokenOut(uint256 inAmount, address stablecoin)
        external
        view
        returns (uint256 superstateTokenOutAmount, uint256 stablecoinInAmountAfterFee, uint256 feeOnStablecoinInAmount);

    /**
     * @notice Processes a subscription
     * @param to The recipient of the minted tokens
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     */
    function subscribe(address to, uint256 inAmount, address stablecoin) external;

    /**
     * @notice Processes a subscription with the caller as the recipient
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     */
    function subscribe(uint256 inAmount, address stablecoin) external;

    /**
     * @dev Emitted when a stablecoin configuration is updated
     */
    event SetStablecoinConfig(
        address indexed stablecoin,
        address oldSweepDestination,
        address newSweepDestination,
        uint96 oldFee,
        uint96 newFee
    );

    /**
     * @dev Emitted when stablecoins are used to Subscribe to a Superstate fund
     * @param subscriber The address that paid the stablecoin (msg.sender)
     * @param to The address that received the minted fund tokens
     * @param stablecoin The stablecoin used to subscribe
     * @param stablecoinInAmountAfterFee The stablecoin amount applied to the mint after the fee
     * @param stablecoinInAmountBeforeFee The gross stablecoin amount deposited
     * @param superstateTokenOutAmount The amount of fund tokens minted
     * @param usdPerSuperstateTokenChainlinkRaw The Chainlink NAV price (USD per fund token, in oracle
     *        feed decimals) used to price this subscription
     */
    event Subscribe(
        address indexed subscriber,
        address indexed to,
        address stablecoin,
        uint256 stablecoinInAmountAfterFee,
        uint256 stablecoinInAmountBeforeFee,
        uint256 superstateTokenOutAmount,
        uint256 usdPerSuperstateTokenChainlinkRaw
    );

    /**
     * @dev V5.1-compatible subscription event emitted alongside `Subscribe`
     * @param subscriber The address that paid the stablecoin (msg.sender)
     * @param to The address that received the minted fund tokens
     * @param stablecoin The stablecoin used to subscribe
     * @param stablecoinInAmountAfterFee The stablecoin amount applied to the mint after the fee
     * @param stablecoinInAmountBeforeFee The gross stablecoin amount deposited
     * @param superstateTokenOutAmount The amount of fund tokens minted
     */
    event SubscribeV2(
        address indexed subscriber,
        address indexed to,
        address stablecoin,
        uint256 stablecoinInAmountAfterFee,
        uint256 stablecoinInAmountBeforeFee,
        uint256 superstateTokenOutAmount
    );

    /**
     * @dev Error thrown when a stablecoin is not supported
     */
    error StablecoinNotSupported();

    /**
     * @dev Error thrown when fee is too high
     */
    error FeeTooHigh();

    /**
     * @dev Error thrown when zero tokens would be output
     */
    error ZeroSuperstateTokensOutSubscribable();

    /**
     * @dev Error thrown when bad args are provided
     */
    error BadArgsSubscribable();
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/utils/StorageSlotUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}

// protocol/token/src/components/AccountingPausable.sol

/**
 * @title AccountingPausable
 * @notice Abstract contract implementing pausable accounting functionality with ERC-7201 namespaced storage
 * @dev Allows pausing of minting and burning operations independently from transfers.
 *      The global `pause()` (PausableUpgradeable) freezes user transfers and subscriptions; this
 *      accounting pause freezes all issuance and burn paths (mint, bulkMint, adminBurn, offchainRedeem,
 *      bridge, buyTheDip, subscribe, and book-entry transfer-to-self). The two flags are orthogonal.
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract AccountingPausable is IAccountingPausable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.accountingPausable
     */
    struct AccountingPausableStorage {
        bool accountingPaused;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.accountingPausable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ACCOUNTING_PAUSABLE_STORAGE_LOCATION =
        0xa9bb159d35c3405794a368b076cfb461c3cfec91ff00ca1c544d07e26a468e00;

    /* Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
    */

    /**
     * @dev Hook to require authorization for pausing/unpausing
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual;

    /*
        Provides the following to be used:
        1. accountingPause() - pauses accounting operations, _requireAuth
        2. accountingUnpause() - unpauses accounting operations, _requireAuth
        3. isAccountingPaused() - returns whether accounting is paused, view only
    */

    /**
     * @dev Pauses accounting operations (minting and burning)
     * @notice Can only be called by authorized addresses (defined in inheriting contract)
     */
    function accountingPause() external virtual {
        _requireAuth();
        if (isAccountingPaused()) revert AccountingIsPaused();

        _setAccountingPaused(true);
        emit AccountingPaused(msg.sender);
    }

    /**
     * @dev Unpauses accounting operations
     * @notice Can only be called by authorized addresses (defined in inheriting contract)
     */
    function accountingUnpause() external virtual {
        _requireAuth();
        if (!isAccountingPaused()) revert AccountingIsNotPaused();

        _setAccountingPaused(false);
        emit AccountingUnpaused(msg.sender);
    }

    /**
     * @dev Returns whether accounting is currently paused
     * @return True if accounting is paused, false otherwise
     */
    function isAccountingPaused() public view virtual returns (bool) {
        AccountingPausableStorage storage $ = _getAccountingPausableStorage();
        return $.accountingPaused;
    }

    /**
     * @dev Returns the AccountingPausableStorage struct
     * @return $ Storage pointer to the AccountingPausableStorage struct
     */
    function _getAccountingPausableStorage() private pure returns (AccountingPausableStorage storage $) {
        assembly {
            $.slot := ACCOUNTING_PAUSABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Sets the paused state of accounting
     * @param paused The new paused state
     */
    function _setAccountingPaused(bool paused) internal {
        AccountingPausableStorage storage $ = _getAccountingPausableStorage();
        $.accountingPaused = paused;
    }

    function __AccountingPausable_init() internal {
        _setAccountingPaused(false); // Unnecessary as starts false by default, done for clarity
    }
}

// protocol/token/src/components/Bridgeable.sol

/**
 * @title Bridgeable
 * @notice Abstract contract implementing cross-chain bridging functionality with ERC-7201 namespaced storage
 * @dev Allows tokens to be burned on one chain and minted on another chain via off-chain settlement.
 *      Chain ID 0 is reserved for book-entry conversions (burn to Superstate's off-chain ledger).
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - Configurable supported chain IDs for bridging destinations
 *      - Support for both EVM (address) and non-EVM (string) destination addresses
 *      - Book-entry conversion via chain ID 0
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract Bridgeable is IBridgeable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.bridgeable
     */
    struct BridgeableStorage {
        mapping(uint256 chainId => bool supported) supportedChainIds;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.bridgeable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BRIDGEABLE_STORAGE_LOCATION =
        0xe4e4f071f9b1db3b4b73cfb89f93997eef9d90809fdd474c473bf010d9361e00;
    /*
        Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
        2. _requireNotAccountingPaused() must be implemented by the inheriting contract
        3. _requireAllowed() must be implemented by the inheriting contract
        4. _burn() must be implemented by the inheriting contract
    */

    /**
     * @dev Hook to require authorization for administrative actions
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual;

    /**
     * @dev Hook to verify accounting (minting and burning) is not paused
     * @notice Must be implemented by inheriting contract
     */
    function _requireNotAccountingPaused() internal view virtual;

    /**
     * @dev Hook to verify if an address is allowed
     * @param addr The address to check
     * @notice Must be implemented by inheriting contract
     */
    function _requireAllowed(address addr) internal view virtual;

    /**
     * @dev Hook to burn tokens
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     * @notice Must be implemented by inheriting contract
     */
    function _burn(address from, uint256 amount) internal virtual;

    /*
        Provides the following to be used:
        1. setChainIdSupport(uint256 chainId, bool supported) - sets support status for a specific chain ID, _requireAuth
        2. isChainIdSupported(uint256 chainId) public view
        3. bridge(uint256 amount,
        address ethDestinationAddress,
        string memory otherDestinationAddress,
        uint256 chainId)
        4. bridgeToBookEntry(uint256 amount)
    */
    /**
     * @dev Returns whether a chain ID is supported for bridging
     * @param chainId The chain ID to check
     * @return True if the chain ID is supported, false otherwise
     */
    function isChainIdSupported(uint256 chainId) public view returns (bool) {
        BridgeableStorage storage $ = _getBridgeableStorage();
        return $.supportedChainIds[chainId];
    }

    /**
     * @dev Sets support status for a specific chain ID
     * @param chainId The chain ID to update
     * @param supported Whether the chain ID should be supported
     */
    function setChainIdSupport(uint256 chainId, bool supported) external virtual {
        _requireAuth();

        _setChainIdSupport(chainId, supported);
    }

    /**
     * @notice Burns tokens from the caller to bridge to another chain
     * @dev Reverts if chainId is not supported.
     * @dev If destination address on chainId isn't on allowlist on the other chain, tokens burn to book entry.
     * @dev Use chainId 0 to burn tokens to Superstate book entry.
     * @param amount Amount of tokens to burn
     * @param ethDestinationAddress ETH address to send to on another chain
     * @param otherDestinationAddress Non-EVM addresses to send to on another chain
     * @param chainId Numerical identifier of destination chain to send tokens to
     */
    function bridge(
        uint256 amount,
        address ethDestinationAddress,
        string memory otherDestinationAddress,
        uint256 chainId
    ) public virtual {
        _requireNotAccountingPaused();
        _requireAllowed(msg.sender);

        if (amount == 0) revert ZeroSuperstateTokensOutBridgeable();

        if (ethDestinationAddress != address(0) && bytes(otherDestinationAddress).length != 0) {
            revert TwoDestinationsInvalid();
        }

        if (chainId == 0 && (ethDestinationAddress != address(0) || bytes(otherDestinationAddress).length != 0)) {
            revert OnchainDestinationSetForBridgeToBookEntry();
        }

        if (!isChainIdSupported(chainId)) revert BridgeChainIdDestinationNotSupported();

        _burn(msg.sender, amount);

        emit Bridge({
            caller: msg.sender,
            src: msg.sender,
            amount: amount,
            ethDestinationAddress: ethDestinationAddress,
            otherDestinationAddress: otherDestinationAddress,
            chainId: chainId
        });
    }

    /**
     * @dev Burns tokens from the caller to bridge to Superstate book entry
     * @param amount Amount of tokens to burn
     */
    function bridgeToBookEntry(uint256 amount) external virtual {
        bridge({
            amount: amount,
            ethDestinationAddress: address(0),
            otherDestinationAddress: string(new bytes(0)),
            chainId: 0
        });
    }
    /**
     * @dev Returns the BridgeableStorage struct
     * @return $ Storage pointer to the BridgeableStorage struct
     */

    function _getBridgeableStorage() private pure returns (BridgeableStorage storage $) {
        assembly {
            $.slot := BRIDGEABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Sets support status for a chain ID
     * @param chainId The chain ID to update
     * @param supported Whether the chain ID should be supported
     */
    function _setChainIdSupport(uint256 chainId, bool supported) internal {
        BridgeableStorage storage $ = _getBridgeableStorage();

        bool oldSupported = $.supportedChainIds[chainId];
        if (oldSupported == supported) revert BadArgsBridgeable();
        if (chainId == block.chainid) revert BridgeChainIdDestinationNotSupported();

        $.supportedChainIds[chainId] = supported;

        emit SetChainIdSupport({chainId: chainId, oldSupported: oldSupported, newSupported: supported});
    }

    function __Bridgeable_init() internal {
        // Support chainId 0 for book entry
        _setChainIdSupport(0, true);
    }
}

// protocol/token/src/base/ERC20MetadataSettable.sol

/**
 * @title ERC20MetadataSettable
 * @notice Abstract component for owner-controlled ERC20 name and symbol updates
 * @dev OZ `ERC20Upgradeable` stores `_name` and `_symbol` as private strings and only writes
 *      them from `__ERC20_init_unchained` under `onlyInitializing`. This component writes the
 *      inherited continuous-layout slots directly via `StorageSlotUpgradeable.getStringSlot`, so
 *      the compiler still emits the correct short/long string encoding.
 *
 *      Slot reference, inherited from `ERC20Upgradeable` through the token core:
 *      - Slot 54: `_name`
 *      - Slot 55: `_symbol`
 *
 *      Re-verify with `forge inspect FundToken storage` / `forge inspect EquityToken storage` if any
 *      inherited contract is upgraded or reordered.
 *
 * @dev This mixin only makes sense on top of {SuperstateTokenCore}'s linearization, which pins
 *      `_name`/`_symbol` to slots 54/55. To make that dependency structural rather than a loose
 *      convention, `SuperstateTokenCore is ERC20MetadataSettable` (this is its base, co-located in
 *      `src/base/`) — so tokens get these setters via the core and never mix this in against a
 *      foreign layout. The full layout table lives in {SuperstateTokenCore}; the 54/55 invariant is
 *      pinned by `FundTokenV5StorageLayoutTests`.
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract ERC20MetadataSettable {
    /// @dev Storage slot of `ERC20Upgradeable._name`.
    bytes32 private constant ERC20_NAME_SLOT = bytes32(uint256(54));

    /// @dev Storage slot of `ERC20Upgradeable._symbol`.
    bytes32 private constant ERC20_SYMBOL_SLOT = bytes32(uint256(55));

    /// @notice Emitted when the token name is updated by the owner
    /// @param oldName The previous name returned by `name()`
    /// @param newName The new name returned by `name()`
    event NameSet(string oldName, string newName);

    /// @notice Emitted when the token symbol is updated by the owner
    /// @param oldSymbol The previous symbol returned by `symbol()`
    /// @param newSymbol The new symbol returned by `symbol()`
    event SymbolSet(string oldSymbol, string newSymbol);

    /// @notice Reverts when attempting to set an empty token name
    error InvalidName();

    /// @notice Reverts when attempting to set an empty token symbol
    error InvalidSymbol();

    /*
        Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
    */

    /**
     * @dev Hook to require authorization for administrative actions
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual;

    /**
     * @notice Updates the token name returned by `name()`
     * @param newName The new token name (must be non-empty)
     *
     * @dev Owner-only. Writes directly to `ERC20Upgradeable._name` (slot 54 in the continuous
     *      storage layout), so all read paths — `name()`, derived `_name()`, and the EIP-712
     *      `DOMAIN_SEPARATOR` (which hashes `_name()` on every call) — automatically reflect the
     *      new value. Because the domain separator changes, any in-flight permit signatures bound
     *      to the previous name are invalidated.
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws InvalidName if `newName` is empty
     * @custom:event Emits NameSet(oldName, newName)
     */
    function setName(string calldata newName) public virtual {
        _requireAuth();
        _setName(newName);
    }

    function _setName(string calldata newName) internal {
        if (bytes(newName).length == 0) revert InvalidName();

        string memory oldName = StorageSlotUpgradeable.getStringSlot(ERC20_NAME_SLOT).value;
        StorageSlotUpgradeable.getStringSlot(ERC20_NAME_SLOT).value = newName;

        emit NameSet(oldName, newName);
    }

    /**
     * @notice Updates the token symbol returned by `symbol()`
     * @param newSymbol The new token symbol (must be non-empty)
     *
     * @dev Owner-only. Writes directly to `ERC20Upgradeable._symbol` (slot 55 in the continuous
     *      storage layout) via `StorageSlotUpgradeable.getStringSlot` for the same reason as
     *      `setName`: OZ exposes no runtime setter and `_symbol` is `string private`.
     *
     * @dev Allowlist implications:
     *      - Private instruments: `Allowlistable.isAllowed(addr)` calls
     *        `IAllowlistAddressPermissions.isAddressAllowedForPrivateInstrument(addr, symbol())`,
     *        so renaming the symbol re-keys the allowlist. Entities permissioned under the prior
     *        symbol will no longer pass `isAllowed` until re-permissioned under the new symbol.
     *        Admin operators must coordinate the symbol change with the allowlist contract.
     *      - Public instruments: the public-instrument lookup does not take a symbol, so this
     *        re-keying does not apply.
     *
     * @dev EIP-712: the permit domain separator hashes `_name()`, not the symbol, so symbol
     *      changes do not invalidate outstanding permit signatures.
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws InvalidSymbol if `newSymbol` is empty
     * @custom:event Emits SymbolSet(oldSymbol, newSymbol)
     */
    function setSymbol(string calldata newSymbol) public virtual {
        _requireAuth();
        _setSymbol(newSymbol);
    }

    function _setSymbol(string calldata newSymbol) internal {
        if (bytes(newSymbol).length == 0) revert InvalidSymbol();

        string memory oldSymbol = StorageSlotUpgradeable.getStringSlot(ERC20_SYMBOL_SLOT).value;
        StorageSlotUpgradeable.getStringSlot(ERC20_SYMBOL_SLOT).value = newSymbol;

        emit SymbolSet(oldSymbol, newSymbol);
    }
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/token/ERC20/extensions/IERC20MetadataUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/interfaces/IERC20Upgradeable.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// protocol/token/src/components/Redeemable.sol

/**
 * @title Redeemable
 * @notice Abstract contract implementing redemption functionality with ERC-7201 namespaced storage
 * @dev Enables tokens to be redeemed through a dedicated redemption contract.
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - Configurable redemption contract address
 *      - Integration point for on-chain redemption workflows
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract Redeemable is IRedeemable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.redeemable
     */
    struct RedeemableStorage {
        address redemptionContract;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.redeemable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REDEEMABLE_STORAGE_LOCATION =
        0x42cf13beef4be89e96f7a42d686186f293b460f8ac2f0416fbe254d1afb6ff00;

    /*  Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
        2. _requireNotAccountingPaused() must be implemented by the inheriting contract
        3. _requireAllowed() must be implemented by the inheriting contract
        4. _burn() must be implemented by the inheriting contract
    */

    /*
        Provides the following to be used on inheritance:
        1. offchainRedeem(amount) - burns token and emits offchainRedeem
        2. getRedemptionContract - returns the redemption contract
        3. setRedemptionContract - sets the redemption contract, auth only

    */

    /**
     * @dev Burns tokens from the caller's address for offchain redemption
     * @param amount Amount of tokens to burn
     */
    function offchainRedeem(uint256 amount) external virtual {
        _requireNotAccountingPaused();
        _requireAllowed(msg.sender);

        _burn(msg.sender, amount);
        emit OffchainRedeem(msg.sender, msg.sender, amount);
    }

    /**
     * @dev Returns the RedeemableStorage struct
     * @return $ Storage pointer to the RedeemableStorage struct
     */
    function _getRedeemableStorage() private pure returns (RedeemableStorage storage $) {
        assembly {
            $.slot := REDEEMABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Returns the current redemption contract address
     * @return The address of the redemption contract
     */
    function getRedemptionContract() public view returns (address) {
        RedeemableStorage storage $ = _getRedeemableStorage();
        return $.redemptionContract;
    }

    /**
     * @dev Sets the redemption contract address
     * @param _newRedemptionContract The new redemption contract address
     */
    function _setRedemptionContract(address _newRedemptionContract) internal {
        RedeemableStorage storage $ = _getRedeemableStorage();

        if ($.redemptionContract == _newRedemptionContract) revert BadArgsRedeemable();

        emit SetRedemptionContract($.redemptionContract, _newRedemptionContract);
        $.redemptionContract = _newRedemptionContract;
    }

    /**
     * @notice Sets redemption contract address
     * @dev Used for convenience for devs
     * @dev Set to address(0) if no such contract exists for the token
     * @param _newRedemptionContract New contract address
     */
    function setRedemptionContract(address _newRedemptionContract) external virtual {
        _requireAuth();
        _setRedemptionContract(_newRedemptionContract);
    }

    /**
     * @dev Hook to require authorization for administrative actions
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual;

    /**
     * @dev Hook to verify accounting (minting and burning) is not paused
     * @notice Must be implemented by inheriting contract
     */
    function _requireNotAccountingPaused() internal view virtual;

    /**
     * @dev Hook to verify if an address is allowed
     * @param addr The address to check
     * @notice Must be implemented by inheriting contract
     */
    function _requireAllowed(address addr) internal view virtual;

    /**
     * @dev Hook to burn tokens
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     * @notice Must be implemented by inheriting contract
     */
    function _burn(address from, uint256 amount) internal virtual;

    function __Redeemable_init(address redemption) internal {
        // Skip if no redemption contract configured (e.g., USCC migration)
        if (redemption != address(0)) {
            _setRedemptionContract(redemption);
        }
    }
}

// protocol/token/src/components/Allowlistable.sol

/**
 * @title Allowlistable.sol
 * @notice Abstract contract implementing allowlist functionality with ERC-7201 namespaced storage
 * @dev Enables checking if addresses have permission to interact with the token.
 *      Supports both public instruments (entity-level permissions) and private instruments
 *      (instrument-specific permissions keyed by token symbol).
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - Public/private instrument permission modes
 *      - Delegated permission checks to external allowlist contract
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.1.0
 * @custom:security-contact security@superstate.co
 */
abstract contract Allowlistable is IAllowlistable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.allowlistable
     */
    struct AllowlistableStorage {
        address allowlist;
        bool isPublicInstrument;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.allowlistable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ALLOWLISTABLE_STORAGE_LOCATION =
        0x20f9d398b060d72baa41f68a4a570507058bbfd6bb960620e2b61718f38ded00;

    /*
        Provides the following to be used on inheritance:
        1. allowlist() - returns the current allowlist contract address
        2. _setAllowlist(address _newAllowlist) - sets the allowlist contract address
        3. isAllowed(address addr) - checks if an address is allowed (auto-selects public/private check)
        4. isPublicInstrument() - returns whether instrument is public or private
        5. _setIsPublicInstrument(bool _isPublicInstrument) - sets instrument type
        6. symbol() - abstract, must be implemented by inheriting contract
    */

    /**
     * @dev Returns the current allowlist contract
     * @return The allowlist contract instance
     */
    function allowlist() public view virtual returns (address) {
        AllowlistableStorage storage $ = _getAllowlistableStorage();
        return $.allowlist;
    }

    /**
     * @dev Returns whether the instrument is public or private
     * @return True if the instrument is public, false if private
     */
    function isPublicInstrument() public view virtual returns (bool) {
        AllowlistableStorage storage $ = _getAllowlistableStorage();
        return $.isPublicInstrument;
    }

    /**
     * @dev Sets the allowlist contract
     * @param _newAllowlist The new allowlist contract to use
     */
    function _setAllowlist(address _newAllowlist) internal {
        if (_newAllowlist == address(0)) revert ZeroAddressNotAllowed();
        AllowlistableStorage storage $ = _getAllowlistableStorage();
        if ($.allowlist == _newAllowlist) revert AlreadySet();

        emit AllowlistUpdated(address($.allowlist), address(_newAllowlist));
        $.allowlist = _newAllowlist;
    }

    /**
     * @dev Sets whether the instrument is public or private
     * @param _isPublicInstrument True if the instrument is public, false if private
     */
    function _setIsPublicInstrument(bool _isPublicInstrument) internal {
        AllowlistableStorage storage $ = _getAllowlistableStorage();

        emit IsPublicInstrumentUpdated($.isPublicInstrument, _isPublicInstrument);
        $.isPublicInstrument = _isPublicInstrument;
    }

    /**
     * @dev Checks if an address is allowed based on instrument type
     * @param addr The address to check
     * @return True if the address is allowed, false otherwise
     * @notice Automatically uses public or private permission check based on isPublicInstrument().
     *         Uses V3 compat functions on allowlist for smooth AllowlistV3→V4 upgrade.
     */
    function isAllowed(address addr) public view virtual returns (bool) {
        address _allowlist = allowlist();
        if (_allowlist == address(0)) return false;

        if (isPublicInstrument()) {
            return IAllowlistAddressPermissions(_allowlist).isAddressAllowedForPublicInstrument(addr);
        } else {
            return IAllowlistAddressPermissions(_allowlist).isAddressAllowedForPrivateInstrument(addr, symbol());
        }
    }

    /**
     * @dev Returns the token symbol
     * @return The token symbol
     * @notice Inherited from ERC20 in implementing contracts
     */
    function symbol() public view virtual returns (string memory);

    /**
     * @dev Returns the AllowlistableStorage struct
     * @return $ Storage pointer to the AllowlistableStorage struct
     */
    function _getAllowlistableStorage() private pure returns (AllowlistableStorage storage $) {
        assembly {
            $.slot := ALLOWLISTABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Initialize the allowlist during contract initialization
     * @param _allowlist The allowlist contract to set
     * @param _isPublicInstrument Whether the instrument is public (true) or private (false)
     */
    function __Allowlistable_init(address _allowlist, bool _isPublicInstrument) internal {
        _setAllowlist(_allowlist);
        _setIsPublicInstrument(_isPublicInstrument);
    }
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// protocol/token/src/components/OracleConsumable.sol

/**
 * @title OracleConsumable
 * @notice Abstract contract implementing Chainlink oracle consumption with ERC-7201 namespaced storage
 * @dev Enables fetching and validating price data from a Chainlink oracle.
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - Chainlink AggregatorV3Interface integration
 *      - Configurable maximum oracle delay for staleness checks
 *      - Minimum acceptable price floor ($7.00) to prevent manipulation
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract OracleConsumable is IOracleConsumable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.oracleConsumable
     */
    struct OracleConsumableStorage {
        address superstateOracle;
        uint256 maximumOracleDelay;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.oracleConsumable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ORACLE_CONSUMABLE_STORAGE_LOCATION =
        0xa23b43bfe83d41df5f8ed4398624686e341868824ee845f21d830b0276bb0d00;

    /*  Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
        2. _getMinimumAcceptablePrice() must be implemented by the inheriting contract
    */

    /**
     * @dev Hook to require authorization for administrative actions
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual;

    /**
     * @dev Hook to get the minimum acceptable price
     * @notice Must be implemented by inheriting contract
     * @return The minimum acceptable price
     */
    function _getMinimumAcceptablePrice() internal view virtual returns (uint256);

    /*
        Provides the following to be used on inheritance:
        1. superstateOracle() - returns the current oracle contract address, view only
        2. getChainlinkPrice - returns the Chainlink price result tuple(_isBadData, _updatedAt, _price) view only
        3. maximumOracleDelay() - returns the maximum oracle delay, view only
        4. setMaximumOracleDelay(delay) - sets the maximum oracle delay, auth
        5. setOracle(_newOracle) - sets the new oracle, auth
        6. _requireOnchainSubscriptionsEnabled - as titled, gate.
    */

    /**
     * @dev Returns the oracle address
     * @return The address of the oracle
     */
    function superstateOracle() public view returns (address) {
        OracleConsumableStorage storage $ = _getOracleConsumableStorage();
        return $.superstateOracle;
    }
    /**
     * @dev Gets the Chainlink price data
     * @return _isBadData True if the data is stale or below threshold
     * @return _updatedAt The timestamp of the last update
     * @return _price The price from the oracle
     */

    function getChainlinkPrice() external view virtual returns (bool _isBadData, uint256 _updatedAt, uint256 _price) {
        return _getChainlinkPrice();
    }

    /**
     * @dev Returns the maximum oracle delay
     * @return The maximum acceptable delay in seconds
     */
    function maximumOracleDelay() public view returns (uint256) {
        OracleConsumableStorage storage $ = _getOracleConsumableStorage();
        return $.maximumOracleDelay;
    }

    /**
     * @dev Sets the maximum oracle delay
     * @param _newMaxOracleDelay The new maximum delay in seconds
     */
    function setMaximumOracleDelay(uint256 _newMaxOracleDelay) external virtual {
        _requireAuth();
        _setMaximumOracleDelay(_newMaxOracleDelay);
    }

    /**
     * @dev Sets the oracle address
     * @param _newOracle The new oracle address
     */
    function setOracle(address _newOracle) external virtual {
        _requireAuth();
        _setOracle(_newOracle);
    }

    /**
     * @dev Checks if onchain subscriptions are enabled
     */
    function _requireOnchainSubscriptionsEnabled() internal view {
        if (superstateOracle() == address(0) || maximumOracleDelay() == 0) {
            revert OnchainSubscriptionsDisabled();
        }
    }

    /**
     * @dev Sets the oracle address
     * @param _newOracle The new oracle address
     */
    function _setOracle(address _newOracle) internal {
        OracleConsumableStorage storage $ = _getOracleConsumableStorage();

        if (_newOracle == $.superstateOracle) revert BadArgsOracleConsumable();

        emit SetOracle($.superstateOracle, _newOracle);
        $.superstateOracle = _newOracle;
    }

    /**
     * @dev Sets the maximum oracle delay
     * @param _newMaxOracleDelay The new maximum delay in seconds
     * @notice Oracle integration inspired by: https://github.com/FraxFinance/frax-oracles/blob/bd56532a3c33da95faed904a5810313deab5f13c/src/abstracts/ChainlinkOracleWithMaxDelay.sol
     */
    function _setMaximumOracleDelay(uint256 _newMaxOracleDelay) internal {
        OracleConsumableStorage storage $ = _getOracleConsumableStorage();

        if (_newMaxOracleDelay == $.maximumOracleDelay) revert BadArgsOracleConsumable();

        emit SetMaximumOracleDelay($.maximumOracleDelay, _newMaxOracleDelay);
        $.maximumOracleDelay = _newMaxOracleDelay;
    }

    /**
     * @dev Gets the Chainlink price data
     * @return _isBadData True if the data is stale or below threshold
     * @return _updatedAt The timestamp of the last update
     * @return _price The price from the oracle
     */
    function _getChainlinkPrice() internal view returns (bool _isBadData, uint256 _updatedAt, uint256 _price) {
        _requireOnchainSubscriptionsEnabled();

        (, int256 _answer,, uint256 _chainlinkUpdatedAt,) = AggregatorV3Interface(superstateOracle()).latestRoundData();

        // If data is stale or below first price, set bad data to true and return
        // 10_000_000 is $10.000000 in the oracle format (6 decimals), that was our starting NAV per Share price for SUPERSTATE_TOKEN
        // The oracle should never return a price much lower than this

        // If data is stale or below minimum acceptable price, set bad data to true
        _isBadData = _answer < int256(_getMinimumAcceptablePrice())
            || ((block.timestamp - _chainlinkUpdatedAt) > maximumOracleDelay());
        _updatedAt = _chainlinkUpdatedAt;
        _price = uint256(_answer);
    }

    /**
     * @dev Returns the OracleConsumableStorage struct
     * @return $ Storage pointer to the OracleConsumableStorage struct
     */
    function _getOracleConsumableStorage() private pure returns (OracleConsumableStorage storage $) {
        assembly {
            $.slot := ORACLE_CONSUMABLE_STORAGE_LOCATION
        }
    }

    function __OracleConsumable_init(address oracle, uint256 maxDelay) internal {
        // Skip if no oracle configured (e.g., USCC migration)
        if (oracle != address(0)) {
            _setOracle(oracle);
            _setMaximumOracleDelay(maxDelay);
        }
    }
}

// protocol/token/src/components/Permittable.sol

/**
 * @title Permittable
 * @notice Abstract contract implementing EIP-712 compliant permit functionality with ERC-7201 namespaced storage
 * @dev Allows approval of token spending through signatures (EIP-2612).
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - EIP-2612 permit() for gasless approvals
 *      - EIP-712 typed structured data signing
 *      - Per-address nonce tracking for replay protection
 *      - Domain separator caching with chain ID validation
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.0.0
 * @custom:security-contact security@superstate.co
 */
abstract contract Permittable is IPermittable {
    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.permittable
     */
    struct PermittableStorage {
        /// @notice The next expected nonce for an address, for validating authorizations via signature
        mapping(address => uint256) nonces;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.permittable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PERMITTABLE_STORAGE_LOCATION =
        0x61eb30d84d4dfa1c5d0f066f60f5c357c05c83c2a042c60a480d47da76483800;
    /* Requirements for implementation:
        1. _approve() must be implemented by the inheriting contract
        2. _name() must be implemented by the inheriting contract, referencing to token name to be used for domain separator
        3. _version() must be implemented by the inheriting contract, referencing to contract version to be used for domain separator
    */

    /**
     * @dev Hook to approve token spending
     * @param owner The token owner
     * @param spender The token spender
     * @param amount The amount of tokens to approve
     * @notice Must be implemented by inheriting contract
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual;

    /**
     * @dev Hook to get the token name
     * @notice Must be implemented by inheriting contract
     * @return The name of the token
     */
    function _name() internal view virtual returns (string memory);

    /**
     * @dev Hook to get the version
     * @notice Must be implemented by inheriting contract
     * @return The version string
     */
    function _version() internal view virtual returns (string memory);

    /*
        Provides the following to be used on inheritance:
        1. nonces(address owner) public view virtual returns (uint256)
        2. permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        3. DOMAIN_SEPARATOR() public view virtual returns (bytes32)
    *
    */

    /**
     * @dev Returns the current nonce for an address
     * @param owner The address to get the nonce for
     * @return The current nonce
     */
    function nonces(address owner) public view virtual returns (uint256) {
        PermittableStorage storage $ = _getPermittableStorage();
        return $.nonces[owner];
    }
    /**
     * @dev Sets approval amount for a spender via signature from signatory
     * @param owner The address that signed the signature
     * @param spender The address to authorize (or rescind authorization from)
     * @param value Amount that `owner` is approving for `spender`
     * @param deadline Expiration time for the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
        virtual
    {
        if (block.timestamp > deadline) revert SignatureExpired();

        uint256 currentNonce = nonces(owner);
        bytes32 structHash =
            keccak256(abi.encode(AUTHORIZATION_TYPEHASH, owner, spender, value, currentNonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));

        if (_isValidSignature(owner, digest, v, r, s)) {
            _incrementNonce(owner);
            _approve(owner, spender, value);
        }
    }
    /**
     * @dev Returns the domain separator used in the encoding of the signature for permit
     * @return bytes32 The domain separator
     */

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH, keccak256(bytes(_name())), keccak256(bytes(_version())), block.chainid, address(this)
            )
        );
    }

    /// @dev The EIP-712 typehash for authorization via permit
    bytes32 internal constant AUTHORIZATION_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /// @dev The EIP-712 typehash for the contract's domain
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /**
     * @dev Returns the PermittableStorage struct
     * @return $ Storage pointer to the PermittableStorage struct
     */
    function _getPermittableStorage() private pure returns (PermittableStorage storage $) {
        assembly {
            $.slot := PERMITTABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Increments the nonce for an address
     * @param owner The address to increment the nonce for
     */
    function _incrementNonce(address owner) internal {
        PermittableStorage storage $ = _getPermittableStorage();
        $.nonces[owner]++;
    }

    /**
     * @dev Checks if a signature is valid
     * @param signer The address that signed the signature
     * @param digest The hashed message that is signed
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     * @return bool Whether the signature is valid
     */
    function _isValidSignature(address signer, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address recoveredSigner, ECDSA.RecoverError recoverError,) = ECDSA.tryRecover(digest, v, r, s);

        if (recoverError == ECDSA.RecoverError.InvalidSignatureS) revert InvalidSignatureS();
        if (recoverError == ECDSA.RecoverError.InvalidSignature) revert BadSignatory();
        if (recoveredSigner != signer) revert BadSignatory();

        return true;
    }

    function __Permittable_init() internal {}
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/security/PausableUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/access/Ownable2StepUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2StepUpgradeable is Initializable, OwnableUpgradeable {
    function __Ownable2Step_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable2Step_init_unchained() internal onlyInitializing {
    }
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// dependencies/openzeppelin-contracts-upgradeable-v4.9.3-4.9.3/contracts/token/ERC20/ERC20Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// dependencies/openzeppelin-contracts-v4.8.0-4.8.0/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// protocol/token/src/interfaces/IFundTokenV1.sol

/**
 * @title IFundTokenV1
 * @notice Comprehensive interface for Superstate's FundToken implementation with subscription and redemption support
 * @dev This interface defines the complete API for Superstate's fund tokens (e.g., USTB, USCC), including:
 *      - ERC20 standard token functionality
 *      - KYC/AML compliance through allowlist integration
 *      - Multi-chain bridging capabilities
 *      - EIP-2612 permit functionality for gasless approvals
 *      - On-chain subscription via stablecoin with Chainlink oracle pricing
 *      - On-chain USDC redemption integration
 *      - Admin controls for minting and burning
 *
 * @dev Interface Composition:
 *      The interface extends multiple specialized interfaces:
 *      - IERC20Upgradeable: Standard ERC20 token operations
 *      - IPermittable: EIP-2612 gasless approval support
 *      - IAccountingPausable: Accounting pause for all mint/burn operations
 *      - IBridgeable: Cross-chain and book-entry transfer capabilities
 *      - IAllowlistable: KYC/AML compliance enforcement
 *      - IRedeemable: On-chain USDC redemption
 *      - ISubscribable: Stablecoin subscription (minting) with oracle pricing
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.3.0
 * @custom:security-contact security@superstate.co
 */
interface IFundTokenV1 is
    IERC20Upgradeable,
    IPermittable,
    IAccountingPausable,
    IBridgeable,
    IAllowlistable,
    IRedeemable,
    ISubscribable
{
    /*//////////////////////////////////////////////////////////////
                    V5.1 COMPATIBILITY GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the fixed six-decimal token precision used by V5.1 integrations
    function SUPERSTATE_TOKEN_PRECISION() external view returns (uint256);

    /// @notice V5.1-compatible alias for `isAccountingPaused()`
    function accountingPaused() external view returns (bool);

    /// @notice V5.1-compatible alias for `allowlist()`
    function allowlistV2() external view returns (address);

    /// @notice V5.1-compatible alias for `getRedemptionContract()`
    function redemptionContract() external view returns (address);

    /// @notice V5.1-compatible alias for `isChainIdSupported(uint256)`
    function supportedChainIds(uint256 chainId) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when attempting to call the disabled renounceOwnership function
    /// @dev Ownership renunciation is permanently disabled to prevent loss of contract control
    error RenounceOwnershipDisabled();

    /// @notice Thrown when attempting an invalid transfer to the token contract itself
    /// @dev Transfers to self are handled specially as off-chain redemption operations
    error InvalidTransferToTokenContract();

    /// @notice Thrown when array parameters have mismatched or zero lengths
    /// @dev Used in bulk operations like bulkMint
    error InvalidArgumentLengths();

    /// @notice Thrown when a caller lacks the required authorization
    /// @dev Typically thrown when non-owner attempts admin operations
    error Unauthorized();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when an admin burns tokens from any address
     * @param burner The admin address that initiated the burn
     * @param src The address from which tokens were burned
     * @param amount The amount of tokens burned (6 decimals)
     *
     * @dev Distinct from standard Transfer event to track admin actions
     * @custom:security Allows tracking of admin-initiated burns for audit purposes
     */
    event AdminBurn(address indexed burner, address indexed src, uint256 amount);

    /**
     * @notice Emitted when new tokens are minted
     * @param minter The admin address that initiated the mint
     * @param to The address receiving the newly minted tokens
     * @param amount The amount of tokens minted (6 decimals)
     *
     * @dev Supplements the standard Transfer event for mint tracking
     * @custom:security Critical for supply tracking and audit trails
     */
    event Mint(address indexed minter, address indexed to, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                        PAUSE MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Pauses all token transfers
     *
     * @dev Emergency Control Function:
     *      - Halts all transfer operations
     *      - Can only be called when currently unpaused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:event Emits Paused event from PausableUpgradeable
     */
    function pause() external;

    /**
     * @notice Unpauses token transfers
     *
     * @dev Resume Operations:
     *      - Re-enables all previously paused transfer operations
     *      - Can only be called when currently paused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:event Emits Unpaused event from PausableUpgradeable
     */
    function unpause() external;

    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns tokens from a specified address (admin function)
     * @param src Address from which tokens will be burned
     * @param amount Amount of tokens to burn (6 decimals)
     *
     * @dev Admin Burn Capabilities:
     *      - Allows admin to burn tokens from any address without approval
     *      - Requires contract not to be paused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:event Emits AdminBurn(admin, src, amount) and Transfer(src, address(0), amount)
     */
    function adminBurn(address src, uint256 amount) external;

    /**
     * @notice Mints new tokens to a specified address
     * @param dst The address to receive the minted tokens
     * @param amount The amount of tokens to mint (6 decimals)
     *
     * @dev Minting Controls:
     *      - Centralized issuance model (admin-only)
     *      - Recipient must be allowlisted
     *      - Cannot mint when paused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:validation dst must pass allowlist checks
     * @custom:event Emits Mint(admin, dst, amount) and Transfer(address(0), dst, amount)
     */
    function mint(address dst, uint256 amount) external;

    /**
     * @notice Mints tokens to multiple recipients in a single transaction
     * @param dsts Array of recipient addresses
     * @param amounts Array of token amounts to mint (6 decimals)
     *
     * @dev Batch Minting:
     *      - Arrays must have matching non-zero lengths
     *      - All recipients must be allowlisted
     *      - Atomic operation (all succeed or all revert)
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws InvalidArgumentLengths if arrays don't match or are empty
     * @custom:event Emits Mint and Transfer events for each recipient
     */
    function bulkMint(address[] calldata dsts, uint256[] calldata amounts) external;

    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets a new allowlist contract address
     * @param _allowlist The address of the new allowlist contract
     *
     * @dev Allowlist Configuration:
     *      - Critical function that changes compliance rules
     *      - Must be non-zero address (validated internally)
     *      - Immediately affects all transfer operations
     *
     * @custom:access-control Only callable by contract owner
     * @custom:validation _allowlist must be non-zero address
     */
    function setAllowlist(address _allowlist) external;

    /**
     * @notice Sets whether the instrument is public or private
     * @dev Only callable by the admin
     * @param _isPublicInstrument True if the instrument is public, false if private
     */
    function setIsPublicInstrument(bool _isPublicInstrument) external;

    /**
     * @notice Updates the token name returned by `name()`
     * @param newName The new token name (must be non-empty)
     *
     * @dev Name Update Semantics:
     *      - Writes the inherited ERC20Upgradeable `_name` slot; subsequent `name()` calls return this value
     *      - EIP-712 domain separator (used by `permit`) derives from `_name()` on each call,
     *        so renaming invalidates any in-flight permit signatures bound to the prior name
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws InvalidName if `newName` is empty
     * @custom:event Emits NameSet(oldName, newName)
     */
    function setName(string calldata newName) external;

    /**
     * @notice Updates the token symbol returned by `symbol()`
     * @param newSymbol The new token symbol (must be non-empty)
     *
     * @dev Symbol Update Semantics:
     *      - Writes the inherited ERC20Upgradeable `_symbol` slot; subsequent `symbol()` calls return this value
     *      - Private instruments: `isAllowed` queries the allowlist keyed by `symbol()`, so renaming the
     *        symbol re-keys the allowlist. Entities permissioned under the prior symbol lose access until
     *        re-permissioned under the new symbol — coordinate with the allowlist operator.
     *      - Public instruments: the public-instrument allowlist lookup is symbol-independent.
     *      - EIP-712 domain separator is unaffected (it hashes `_name()`, not the symbol)
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws InvalidSymbol if `newSymbol` is empty
     * @custom:event Emits SymbolSet(oldSymbol, newSymbol)
     */
    function setSymbol(string calldata newSymbol) external;
}

// protocol/token/src/components/Subscribable.sol

/**
 * @title Subscribable
 * @notice Abstract contract implementing subscription functionality with ERC-7201 namespaced storage
 * @dev Enables token minting through stablecoin deposits at the current Chainlink oracle price.
 *      Subscribers deposit supported stablecoins and receive fund tokens at the current NAV.
 *
 * @dev Key Features:
 *      - ERC-7201 namespaced storage pattern for upgrade safety
 *      - Configurable stablecoin support with per-stablecoin fee and sweep destination
 *      - Chainlink oracle integration for NAV-based pricing
 *      - Subscribe-on-behalf: Any allowlisted address can subscribe for any other allowlisted address
 *      - Fee precision at 0.01% (basis points with 10000 denominator)
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.2.0
 * @custom:security-contact security@superstate.co
 */
abstract contract Subscribable is ISubscribable, IOracleConsumable, OracleConsumable {
    using SafeERC20 for IERC20;
    /// @notice Base 10000 for 0.01% precision

    uint256 public constant FEE_DENOMINATOR = 10_000;

    /**
     * @dev Storage struct using ERC-7201 namespaced pattern
     * @custom:storage-location erc7201:superstate.storage.subscribable
     */
    struct SubscribableStorage {
        mapping(address stablecoin => ISubscribable.StablecoinConfig) supportedStablecoins;
    }

    // keccak256(abi.encode(uint256(keccak256(bytes("superstate.storage.subscribable"))) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SUBSCRIBABLE_STORAGE_LOCATION =
        0x6640ca63ab1055811b2fff34942dd505f4876e53399ef208ab1dce6ae1a05d00;

    /*  Requirements for implementation:
        1. _requireAuth() must be implemented by the inheriting contract
        2. _requireNotPaused() must be implemented by the inheriting contract
        3. _requireNotAccountingPaused() must be implemented by the inheriting contract
        4. _mint() must be implemented by the inheriting contract for token creation
        5. decimals() must be implemented by the inheriting contract
    */

    /**
     * @dev Hook to require authorization for administrative actions
     * @notice Must be implemented by inheriting contract
     */
    function _requireAuth() internal view virtual override;

    /**
     * @dev Hook to check if contract is paused
     * @notice Must be implemented by inheriting contract
     */
    function _requireNotPaused() internal view virtual;

    /**
     * @dev Hook to verify accounting (minting and burning) is not paused
     * @notice Must be implemented by inheriting contract
     */
    function _requireNotAccountingPaused() internal view virtual;

    /**
     * @dev Hook to mint tokens
     * @param to The recipient
     * @param amount The amount to mint
     * @notice Must be implemented by inheriting contract
     */
    function _mint(address to, uint256 amount) internal virtual;

    /**
     * @dev Hook to get the token decimals
     * @notice Must be implemented by inheriting contract
     * @return The token decimals
     */
    function decimals() public pure virtual returns (uint8);

    /*
        Provides the following to be used on inheritance:
        1. supportedStablecoins() - returns the configuration for a stablecoin, view only
        2. setStablecoinConfig() - sets the configuration for a stablecoin (admin function)
        3. calculateFee() - calculates the fee for a subscription amount
        4. calculateSuperstateTokenOut() - calculates the amount of tokens to mint for a subscription
        5. subscribe() - processes a subscription with two variants:
           - subscribe(address to, uint256 inAmount, address stablecoin) - for subscriptions on behalf of another address
           - subscribe(uint256 inAmount, address stablecoin) - for subscriptions to self
    */

    /**
     * @dev Returns the SubscribableStorage struct
     * @return $ Storage pointer to the SubscribableStorage struct
     */
    function _getSubscribableStorage() private pure returns (SubscribableStorage storage $) {
        assembly {
            $.slot := SUBSCRIBABLE_STORAGE_LOCATION
        }
    }

    /**
     * @dev Returns the configuration for a stablecoin
     * @param stablecoin The stablecoin address
     * @return The stablecoin configuration
     */
    function supportedStablecoins(address stablecoin) public view returns (ISubscribable.StablecoinConfig memory) {
        SubscribableStorage storage $ = _getSubscribableStorage();
        return $.supportedStablecoins[stablecoin];
    }

    /**
     * @dev Sets the configuration for a stablecoin
     * @dev Requires msg.sender to be the owner address
     * @param stablecoin The stablecoin address
     * @param newSweepDestination The address to send stablecoins to
     * @param newFee The fee in basis points (max 10 = 0.1%)
     */
    function setStablecoinConfig(address stablecoin, address newSweepDestination, uint96 newFee) external virtual {
        _requireAuth();
        _setStablecoinConfig(stablecoin, newSweepDestination, newFee);
    }

    /**
     * @dev Calculates the fee for a subscription using ceiling division
     * @dev Rounds up to prevent fee avoidance via small transaction splitting
     * @param amount The amount to calculate fee on
     * @param subscriptionFee The fee percentage in basis points
     * @return The fee amount (rounded up)
     */
    function calculateFee(uint256 amount, uint256 subscriptionFee) public pure virtual returns (uint256) {
        uint256 numerator = amount * subscriptionFee;
        return (numerator + FEE_DENOMINATOR - 1) / FEE_DENOMINATOR;
    }

    /**
     * @dev Calculates the amount of tokens to mint for a subscription
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     * @return superstateTokenOutAmount The amount of tokens to mint
     * @return stablecoinInAmountAfterFee The amount of stablecoin after fee
     * @return feeOnStablecoinInAmount The fee amount
     */
    function calculateSuperstateTokenOut(uint256 inAmount, address stablecoin)
        public
        view
        virtual
        returns (uint256 superstateTokenOutAmount, uint256 stablecoinInAmountAfterFee, uint256 feeOnStablecoinInAmount)
    {
        (superstateTokenOutAmount, stablecoinInAmountAfterFee, feeOnStablecoinInAmount,) =
            _calculateSuperstateTokenOut(inAmount, stablecoin);
    }

    /**
     * @dev Shared subscription math. Returns the same `usdPerSuperstateTokenChainlinkRaw` raw
     *      NAV price used to size `superstateTokenOutAmount`. Callers that need to surface the
     *      price (e.g. the `Subscribe` event) take it from here rather than re-reading the
     *      oracle, so the emitted price is exactly the value the mint was priced at — one
     *      oracle read, no chance of a second read drifting.
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     * @return superstateTokenOutAmount The amount of tokens to mint
     * @return stablecoinInAmountAfterFee The amount of stablecoin after fee
     * @return feeOnStablecoinInAmount The fee amount
     * @return usdPerSuperstateTokenChainlinkRaw The raw Chainlink NAV price used for the conversion
     */
    function _calculateSuperstateTokenOut(uint256 inAmount, address stablecoin)
        internal
        view
        returns (
            uint256 superstateTokenOutAmount,
            uint256 stablecoinInAmountAfterFee,
            uint256 feeOnStablecoinInAmount,
            uint256 usdPerSuperstateTokenChainlinkRaw
        )
    {
        StablecoinConfig memory config = supportedStablecoins(stablecoin);
        if (config.sweepDestination == address(0)) revert StablecoinNotSupported();

        feeOnStablecoinInAmount = calculateFee({amount: inAmount, subscriptionFee: config.fee});
        stablecoinInAmountAfterFee = inAmount - feeOnStablecoinInAmount;

        bool isBadData;
        (isBadData,, usdPerSuperstateTokenChainlinkRaw) = _getChainlinkPrice();
        if (isBadData) revert BadChainlinkData();

        uint256 stablecoinDecimals = IERC20Metadata(stablecoin).decimals();
        uint256 stablecoinPrecision = 10 ** stablecoinDecimals;
        uint256 chainlinkFeedPrecision = 10 ** AggregatorV3Interface(superstateOracle()).decimals();

        // Converts from a USD amount to a SUPERSTATE_TOKEN amount
        superstateTokenOutAmount = (stablecoinInAmountAfterFee * chainlinkFeedPrecision * 10 ** decimals())
            / (usdPerSuperstateTokenChainlinkRaw * stablecoinPrecision);
    }

    /**
     * @dev Processes a subscription
     * @param to The recipient of the minted tokens
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     */
    function subscribe(address to, uint256 inAmount, address stablecoin) external virtual {
        _subscribe(to, inAmount, stablecoin);
    }

    /**
     * @dev Processes a subscription with the caller as the recipient
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     */
    function subscribe(uint256 inAmount, address stablecoin) external virtual {
        _subscribe(msg.sender, inAmount, stablecoin);
    }

    /**
     * @dev Sets the configuration for a stablecoin
     * @param stablecoin The stablecoin address
     * @param newSweepDestination The address to send stablecoins to
     * @param newFee The fee in basis points (max 10 = 0.1%)
     */
    function _setStablecoinConfig(address stablecoin, address newSweepDestination, uint96 newFee) internal {
        if (newFee > 10) revert FeeTooHigh(); // Max 0.1% fee

        SubscribableStorage storage $ = _getSubscribableStorage();

        StablecoinConfig memory oldConfig = $.supportedStablecoins[stablecoin];
        if (newSweepDestination == oldConfig.sweepDestination && newFee == oldConfig.fee) revert BadArgsSubscribable();

        $.supportedStablecoins[stablecoin] = StablecoinConfig({sweepDestination: newSweepDestination, fee: newFee});

        emit SetStablecoinConfig({
            stablecoin: stablecoin,
            oldSweepDestination: oldConfig.sweepDestination,
            newSweepDestination: newSweepDestination,
            oldFee: oldConfig.fee,
            newFee: newFee
        });
    }

    /**
     * @dev Processes a subscription
     * @param to The recipient of the minted tokens
     * @param inAmount The amount of stablecoin to subscribe with
     * @param stablecoin The stablecoin address
     * @notice Any caller can subscribe on behalf of any `to` address.
     *         The caller (msg.sender) pays the stablecoin; the `to` address receives the fund tokens.
     *         Both addresses must be allowlisted to hold the fund token.
     */
    function _subscribe(address to, uint256 inAmount, address stablecoin) internal {
        if (inAmount == 0) revert BadArgsSubscribable();
        _requireNotPaused();
        _requireNotAccountingPaused();

        (
            uint256 superstateTokenOutAmount,
            uint256 stablecoinInAmountAfterFee,,
            uint256 usdPerSuperstateTokenChainlinkRaw
        ) = _calculateSuperstateTokenOut({inAmount: inAmount, stablecoin: stablecoin});

        if (superstateTokenOutAmount == 0) revert ZeroSuperstateTokensOutSubscribable();

        IERC20(stablecoin)
            .safeTransferFrom({
                from: msg.sender, to: supportedStablecoins(stablecoin).sweepDestination, value: inAmount
            });

        _mint(to, superstateTokenOutAmount);

        emit Subscribe({
            subscriber: msg.sender,
            to: to,
            stablecoin: stablecoin,
            stablecoinInAmountAfterFee: stablecoinInAmountAfterFee,
            stablecoinInAmountBeforeFee: inAmount,
            superstateTokenOutAmount: superstateTokenOutAmount,
            usdPerSuperstateTokenChainlinkRaw: usdPerSuperstateTokenChainlinkRaw
        });
        emit SubscribeV2({
            subscriber: msg.sender,
            to: to,
            stablecoin: stablecoin,
            stablecoinInAmountAfterFee: stablecoinInAmountAfterFee,
            stablecoinInAmountBeforeFee: inAmount,
            superstateTokenOutAmount: superstateTokenOutAmount
        });
    }

    function __Subscribable_init(address oracle, uint256 maxDelay) internal {
        __OracleConsumable_init(oracle, maxDelay);
    }
}

// protocol/token/src/base/SuperstateTokenCore.sol

/**
 * @title SuperstateTokenCore
 * @notice Abstract base contract providing core ERC20 token functionality with upgradeability
 * @dev Combines OpenZeppelin's ERC20, Pausable, and Ownable2Step upgradeable contracts.
 *      Uses continuous (non-namespaced) storage layout for backward compatibility with
 *      already-deployed Token V5/V5.1 contracts.
 *
 * @dev Two pause flags are exposed by the inheriting token:
 *      - PausableUpgradeable.paused() — global pause; freezes user transfers and subscriptions.
 *      - AccountingPausable.isAccountingPaused() — accounting pause; freezes all issuance and burn
 *        paths (mint, bulkMint, adminBurn, offchainRedeem, bridge, buyTheDip, subscribe, and the
 *        book-entry transfer-to-self burn). The two flags are orthogonal and engaged independently.
 *
 * @dev Key Features:
 *      - ERC20 token with 6 decimals
 *      - Pausable transfers for emergency stops
 *      - Two-step ownership transfer for safety
 *      - Continuous storage layout (slots 0-150) for upgrade compatibility
 *
 * @dev Inherited Continuous Storage Layout (linearized; identical for FundToken and EquityToken —
 *      verify with `forge inspect FundToken storage` / `forge inspect EquityToken storage`, and pinned
 *      for both by `FundTokenV5StorageLayoutTests.testCoreContinuousStorageLayout` and `testNameSymbolSlotPin`):
 *
 *      | Slot     | Field                                | Source contract                                |
 *      |----------|--------------------------------------|------------------------------------------------|
 *      | 0        | _initialized (uint8), _initializing  | Initializable                                  |
 *      | 1..50    | __gap[50]                            | Initializable                                  |
 *      | 51       | _balances (mapping)                  | ERC20Upgradeable                               |
 *      | 52       | _allowances (mapping)                | ERC20Upgradeable                               |
 *      | 53       | _totalSupply (uint256)               | ERC20Upgradeable                               |
 *      | 54       | _name (string)                       | ERC20Upgradeable                               |
 *      | 55       | _symbol (string)                     | ERC20Upgradeable                               |
 *      | 56..100  | __gap[45]                            | ERC20Upgradeable                               |
 *      | 101      | _paused (bool)                       | PausableUpgradeable                            |
 *      | 102..150 | __gap[49]                            | PausableUpgradeable                            |
 *      | 151      | _owner (address)                     | OwnableUpgradeable (via Ownable2StepUpgradeable) |
 *      | 152..200 | __gap[49]                            | OwnableUpgradeable                             |
 *      | 201      | _pendingOwner (address)              | Ownable2StepUpgradeable                        |
 *      | 202..250 | __gap[49]                            | Ownable2StepUpgradeable                        |
 *
 *      Subclasses add further continuous slots beyond 250 (e.g. `initializeV1_2_0` in FundToken
 *      reads `superstateOracle` at slot 756, `allowlistV2` at 758). Newer component state
 *      (accounting-pause, permittable, etc.) lives in ERC-7201 namespaced slots and does not
 *      consume continuous slots.
 *
 * @dev Bundled mixin: this core `is ERC20MetadataSettable`, so every token built on it inherits
 *      owner-controlled `setName`/`setSymbol`. That mixin is deliberately co-located in `src/base/`
 *      and folded in here — rather than mixed into each token independently — precisely because it
 *      depends on this contract's linearization: it writes the `_name`/`_symbol` entries (slots 54
 *      and 55 in the table above) directly. It is storage-less, so it adds no continuous slots; the
 *      coupling is structural, not a layout change. The `FundTokenV5StorageLayoutTests` slot pin
 *      guards the 54/55 invariant the mixin relies on.
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.2.0 (shared by FundToken 1.2.0 / EquityToken 1.4.0)
 * @custom:security-contact security@superstate.co
 */
abstract contract SuperstateTokenCore is
    ERC20Upgradeable,
    PausableUpgradeable,
    Ownable2StepUpgradeable,
    ERC20MetadataSettable
{}

// protocol/token/src/fund/v1.3.0/FundTokenV1_3_0.sol

/**
 * @title FundToken
 * @notice Upgradeable ERC20 token representing tokenized fund instruments (USTB, USCC) with compliance, redemption, and subscription capabilities
 * @dev This contract serves as the core implementation for Superstate's fund token products, providing:
 *      - KYC/AML compliance through allowlist integration
 *      - Multi-chain bridging capabilities with book-entry support
 *      - On-chain redemption via integrated redemption contracts
 *      - NAV-based subscription with oracle price feeds
 *      - EIP-2612 permit functionality for gasless approvals
 *
 * @dev Architecture Overview:
 *      The contract inherits from multiple specialized components:
 *      - SuperstateTokenCore: Base token functionality with upgrade support; also bundles
 *        ERC20MetadataSettable (owner-controlled `setName`/`setSymbol`), which is layout-coupled to
 *        the core and therefore inherited through it rather than mixed in here directly
 *      - AccountingPausable: Accounting pause freezing all mint/burn (issuance and redemption) paths
 *      - Allowlistable: KYC/AML compliance enforcement
 *      - Permittable: EIP-2612 gasless approval support
 *      - Bridgeable: Cross-chain transfer capabilities
 *      - Redeemable: On-chain token redemption mechanics
 *      - Subscribable: NAV-based subscription with stablecoin payments
 *
 * @dev Key Features:
 *      - 6 decimal precision for all token amounts
 *      - Two-step ownership transfer for security
 *      - Global pause (freezes user transfers and subscriptions) and accounting pause
 *        (freezes all mint/burn) as independent emergency controls
 *      - Public/private instrument modes with different allowlist rules
 *      - Admin-controlled minting and burning
 *      - Bridge-to-book-entry via transfer to contract address
 *      - Chainlink oracle integration for NAV pricing
 *      - Minimum acceptable price floor ($7.00) for subscriptions
 *
 * @dev Storage Layout:
 *      Uses EIP-7201 namespaced storage for upgrade safety.
 *      Migration from v5_1 continuous storage handled via initializeV1_2_0().
 *
 * @author Jake Goh Si Yuan @jakegsy (Superstate)
 * @custom:version 1.3.0
 * @custom:security-contact security@superstate.co
 */
contract FundToken is
    IFundTokenV1,
    SuperstateTokenCore,
    AccountingPausable,
    Permittable,
    Allowlistable,
    Bridgeable,
    Redeemable,
    Subscribable
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The version of this contract implementation
    /// @dev Used for upgrade compatibility verification and EIP-712 domain separator
    string public constant VERSION = "1.3.0";

    /// @notice Token decimal precision (matches USDC standard)
    /// @dev All token amounts use 6 decimal places for consistency
    uint8 private constant DECIMALS = 6;

    /// @notice V5.1-compatible getter for the token precision
    /// @dev Retained so integrations using the legacy selector continue to return 1e6
    uint256 public constant SUPERSTATE_TOKEN_PRECISION = 10 ** DECIMALS;

    /// @notice Lowest acceptable Chainlink oracle price for subscriptions
    /// @dev Set to $7.00 (7_000_000 in 6 decimals) as a safety floor
    uint256 public immutable MINIMUM_ACCEPTABLE_PRICE;

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & INITIALIZERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Disables initializers to prevent implementation contract misuse
     * @dev This is the implementation contract; actual instances must call initialize() via proxy
     *      Sets MINIMUM_ACCEPTABLE_PRICE to $7.00 as a safety floor for oracle prices
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        // SUPERSTATE_TOKEN starts at $10.000000, Chainlink oracle with 6 decimals would represent as 10_000_000.
        // This math will give us 7_000_000 or $7.000000.
        MINIMUM_ACCEPTABLE_PRICE = 7 * (10 ** uint256(DECIMALS));

        _disableInitializers();
    }

    /**
     * @notice Initializes the proxy contract instance for fresh deployments
     * @param name_ The token name (e.g., "Superstate USTB")
     * @param symbol_ The token symbol (e.g., "USTB")
     * @param allowlist The allowlist contract address for KYC/AML compliance
     * @param _isPublicInstrument Whether this is a public instrument (true) or private instrument (false)
     * @param redemption The redemption contract address for on-chain redemptions
     * @param oracle The Chainlink oracle contract address for NAV pricing
     * @param maxDelay The maximum acceptable oracle staleness in seconds
     *
     * @dev Initialization Sequence:
     *      1. ERC20 base initialization with name and symbol
     *      2. Pausable initialization (sets paused = false)
     *      3. AccountingPausable initialization (sets accountingPaused = false)
     *      4. Permittable initialization (prepares EIP-2612 support)
     *      5. Allowlistable initialization (sets allowlist contract and instrument type)
     *      6. Bridgeable initialization (enables book-entry with chain_id = 0)
     *      7. Redeemable initialization (sets redemption contract)
     *      8. Subscribable initialization (sets oracle and max delay)
     *
     * @custom:security Can only be called once per proxy deployment
     * @custom:validation allowlist must be non-zero address
     * @custom:event Emits OwnershipTransferred with (address(0), msg.sender)
     */
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address allowlist,
        bool _isPublicInstrument,
        address redemption,
        address oracle,
        uint256 maxDelay
    ) public initializer {
        __ERC20_init(name_, symbol_);
        __Ownable2Step_init(); // Sets msg.sender as owner
        __Pausable_init();
        __AccountingPausable_init(); // sets accountingPaused = false
        __Permittable_init(); // doesnt really do anything, for consistency
        __Allowlistable_init(allowlist, _isPublicInstrument); // sets allowlist and instrument type
        __Bridgeable_init(); // sets chainId 0 for book entry to true
        __Redeemable_init(redemption); // sets redemption contract
        __Subscribable_init(oracle, maxDelay); // sets oracle and maxDelay, no stablecoins initialized
    }

    /**
     * @notice Migrates existing deployments and atomically replays non-enumerable mapping config
     * @param stablecoins Stablecoin addresses to configure after namespace initialization
     * @param stablecoinConfigs Stablecoin sweep destination and fee configs aligned with `stablecoins`
     * @param supportedChainIds_ Bridge destination chain IDs to mark supported after namespace initialization
     *
     * @dev Migration Details:
     *      - Reads state from v5_1 continuous storage slots (see forge inspect SuperstateTokenV5_1 storageLayout)
     *      - Initializes all component namespaces with migrated state
     *      - Sets instrument type to private (existing USTB/USCC behavior)
     *      - Replays mapping data (supportedStablecoins, supportedChainIds) supplied by the caller
     *
     * @dev Solidity mappings are not enumerable on-chain, so callers must supply the known keys captured
     *      before the upgrade. Pass empty arrays when there is no mapping config to replay. This keeps the
     *      storage migration and mapping replay in one owner transaction.
     *
     * @dev Storage Slot Reference (v5_1):
     *      - Slot 754: accountingPaused
     *      - Slot 755: maximumOracleDelay
     *      - Slot 756: superstateOracle
     *      - Slot 758: allowlistV2
     *      - Slot 759: redemptionContract
     *
     * @custom:access-control Only callable by contract owner
     * @custom:security Uses reinitializer(6) to prevent re-execution
     * @custom:migration For existing USTB/USCC deployments only; fresh deployments use initialize()
     */
    function initializeV1_2_0(
        address[] calldata stablecoins,
        ISubscribable.StablecoinConfig[] calldata stablecoinConfigs,
        uint256[] calldata supportedChainIds_
    ) external reinitializer(6) {
        _requireAuth();
        _initializeV1_2_0();
        _initializeV1_2_0MigrationConfig(stablecoins, stablecoinConfigs, supportedChainIds_);
    }

    function _initializeV1_2_0() internal {
        // Read v5_1 state from continuous storage slots
        // See `forge inspect SuperstateTokenV5_1 storageLayout` for reference
        bool legacyAccountingPaused = _getBoolFromSlot(754); // accountingPaused
        uint256 maxDelay = _getUint256FromSlot(755); // maximumOracleDelay
        address oracle = _getAddressFromSlot(756); // superstateOracle
        address allowlist = _getAddressFromSlot(758); // allowlistV2
        address redemption = _getAddressFromSlot(759); // redemptionContract

        // Initialize all component namespaces with migrated state
        __AccountingPausable_init(); // Accounting pause starts disengaged in the new ERC-7201 namespace
        // Carry over the v5_1 accounting-pause flag (continuous slot 754). Without this, migrating while
        // accounting-paused (e.g. during an incident) would silently re-enable all mint/burn/bridge/redeem/
        // subscribe paths while paused() still reports true, diverging the two pause levers.
        _setAccountingPaused(legacyAccountingPaused);
        __Permittable_init(); // Nonces reset to 0 in ERC-7201 namespace; old signatures invalid due to new VERSION in domain separator
        __Allowlistable_init(allowlist, false); // Migrate allowlist, set as private instrument
        __Bridgeable_init(); // Initialize chainId 0 support for book entry
        __Redeemable_init(redemption); // Migrate redemption contract
        __Subscribable_init(oracle, maxDelay); // Migrate oracle and delay settings
    }

    function _initializeV1_2_0MigrationConfig(
        address[] calldata stablecoins,
        ISubscribable.StablecoinConfig[] calldata stablecoinConfigs,
        uint256[] calldata supportedChainIds_
    ) internal {
        if (stablecoins.length != stablecoinConfigs.length) revert InvalidArgumentLengths();

        for (uint256 i = 0; i < stablecoins.length; ++i) {
            _setStablecoinConfig({
                stablecoin: stablecoins[i],
                newSweepDestination: stablecoinConfigs[i].sweepDestination,
                newFee: stablecoinConfigs[i].fee
            });
        }

        for (uint256 i = 0; i < supportedChainIds_.length; ++i) {
            _setChainIdSupport(supportedChainIds_[i], true);
        }
    }

    function _getAddressFromSlot(uint256 slot) internal view returns (address) {
        address result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function _getUint256FromSlot(uint256 slot) internal view returns (uint256) {
        uint256 result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function _getBoolFromSlot(uint256 slot) internal view returns (bool) {
        uint256 result;
        assembly {
            result := sload(slot)
        }
        return result != 0;
    }

    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets a new allowlist contract address
     * @param _allowlist The address of the new allowlist contract
     *
     * @dev Security Considerations:
     *      - Critical function that changes compliance rules
     *      - _setAllowlist validates non-zero address internally
     *      - Immediately affects all transfer operations
     *
     * @custom:access-control Only callable by contract owner
     * @custom:validation _allowlist must be non-zero address
     * @custom:event Emits AllowlistSet with new allowlist address
     */
    function setAllowlist(address _allowlist) external {
        _requireAuth();
        _setAllowlist(_allowlist);
    }

    /**
     * @notice Sets whether this token is a public or private instrument
     * @param _isPublicInstrument True for public instrument, false for private
     *
     * @dev Instrument Type Implications:
     *      - Public: Uses entity-based allowlist permissions
     *      - Private: Uses instrument-specific allowlist permissions with token symbol
     *      This affects how isAllowed() queries the allowlist contract
     *
     * @custom:access-control Only callable by contract owner
     * @custom:event Emits IsPublicInstrumentSet with new setting
     */
    function setIsPublicInstrument(bool _isPublicInstrument) external {
        _requireAuth();
        _setIsPublicInstrument(_isPublicInstrument);
    }

    /*//////////////////////////////////////////////////////////////
                        PAUSE MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Engages the global pause, freezing user transfers and subscriptions
     *
     * @dev Emergency Control:
     *      - Blocks regular transfers/transferFrom and subscribe
     *      - Does NOT block mint/burn paths — those are gated by the separate accounting pause
     *        (mint, bulkMint, adminBurn, offchainRedeem, bridge, book-entry transfer-to-self)
     *      - Independent of accountingPause(); each is engaged/released separately
     *      - Can only pause if currently unpaused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws AlreadyPaused if contract is already paused
     * @custom:event Emits Paused(owner)
     */
    function pause() external {
        _checkOwner();
        _requireNotPaused();

        _pause();
    }

    /**
     * @notice Releases the global pause, re-enabling transfers and subscriptions
     *
     * @dev Resume Operations:
     *      - Re-enables regular transfers and subscribe
     *      - Can only unpause if currently paused
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws NotPaused if contract is not paused
     * @custom:event Emits Unpaused(owner)
     */
    function unpause() external {
        _checkOwner();
        _requirePaused();

        _unpause();
    }

    /**
     * @notice Permanently disabled ownership renunciation
     *
     * @dev Security Feature:
     *      - Prevents accidental loss of contract control
     *      - Ownership can still be transferred via two-step process
     *      - Always reverts with RenounceOwnershipDisabled
     *
     * @custom:security Critical safety feature to prevent permanent loss of admin control
     * @custom:throws RenounceOwnershipDisabled always
     */
    function renounceOwnership() public virtual override onlyOwner {
        revert RenounceOwnershipDisabled();
    }

    /*//////////////////////////////////////////////////////////////
                        TOKEN METADATA
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the number of decimals used for token amounts
     * @return uint8 Always returns 6
     *
     * @dev Fixed at 6 decimals for all Superstate tokens (matches USDC standard)
     * @custom:invariant This value never changes
     */
    function decimals() public pure override(ERC20Upgradeable, Subscribable) returns (uint8) {
        return DECIMALS;
    }

    /**
     * @notice Returns the token symbol
     * @return The token symbol
     * @dev Overrides both ERC20Upgradeable and Allowlistable to resolve inheritance conflict
     */
    function symbol() public view override(ERC20Upgradeable, Allowlistable) returns (string memory) {
        return super.symbol();
    }

    /*//////////////////////////////////////////////////////////////
                        TOKEN TRANSFER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Moves tokens from caller to destination address
     * @param dst Address to receive the tokens
     * @param amount Amount of tokens to transfer (6 decimals)
     * @return bool Always returns true on success (reverts on failure)
     *
     * @dev Special Behavior:
     *      - If dst == address(this): Burns tokens and emits OffchainRedeem event (book-entry conversion)
     *      - Otherwise: Standard ERC20 transfer with allowlist checks
     *
     * @custom:validation Both sender and recipient must be allowlisted
     * @custom:throws Paused if contract is paused
     * @custom:throws InsufficientPermissions if sender or recipient not allowlisted
     * @custom:event Emits Transfer(msg.sender, dst, amount) or OffchainRedeem for book-entry
     */
    function transfer(address dst, uint256 amount) public override(IERC20Upgradeable, ERC20Upgradeable) returns (bool) {
        if (!isAllowed(msg.sender)) revert InsufficientPermissions();

        if (dst == address(this)) {
            _requireNotAccountingPaused();
            _burn(msg.sender, amount);
            emit OffchainRedeem({burner: msg.sender, src: msg.sender, amount: amount});
        } else {
            _requireNotPaused();
            if (!isAllowed(dst)) revert InsufficientPermissions();
            _transfer(msg.sender, dst, amount);
        }

        return true;
    }

    /**
     * @notice Moves tokens from source to destination using caller's allowance
     * @param src Address to transfer tokens from
     * @param dst Address to receive the tokens
     * @param amount Amount of tokens to transfer (6 decimals)
     * @return bool Always returns true on success (reverts on failure)
     *
     * @dev Special Behavior:
     *      - If dst == address(this): Burns from src and emits OffchainRedeem event
     *      - Allowance is always consumed regardless of destination
     *      - Caller can be different from src (uses allowance mechanism)
     *
     * @custom:validation src and dst must be allowlisted
     * @custom:throws Paused if contract is paused
     * @custom:throws InsufficientPermissions if src or dst not allowlisted
     * @custom:throws InsufficientAllowance if caller lacks allowance
     * @custom:event Emits Transfer(src, dst, amount) or OffchainRedeem for book-entry
     */
    function transferFrom(address src, address dst, uint256 amount)
        public
        override(IERC20Upgradeable, ERC20Upgradeable)
        returns (bool)
    {
        if (!isAllowed(src)) revert InsufficientPermissions();

        if (dst == address(this)) {
            _requireNotAccountingPaused();
            _spendAllowance({owner: src, spender: msg.sender, amount: amount});
            _burn(src, amount);
            // burner receives redemption payout from src
            emit OffchainRedeem({burner: msg.sender, src: src, amount: amount});
        } else {
            _requireNotPaused();
            if (!isAllowed(dst)) revert InsufficientPermissions();
            ERC20Upgradeable.transferFrom({from: src, to: dst, amount: amount});
        }

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                        MINTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints new tokens to a specified address
     * @param dst The address to receive the minted tokens
     * @param amount The amount of tokens to mint (6 decimals)
     *
     * @dev Minting Constraints:
     *      - Only owner can mint (centralized issuance model)
     *      - Recipient must be allowlisted
     *
     * @custom:access-control Only callable by contract owner
     * @custom:validation dst must be allowlisted
     * @custom:throws InsufficientPermissions if dst not allowlisted
     * @custom:event Emits Mint(owner, dst, amount) and Transfer(address(0), dst, amount)
     */
    function mint(address dst, uint256 amount) external {
        _checkOwner();
        _requireNotAccountingPaused();

        _mint(dst, amount);
    }

    /**
     * @notice Mints tokens to multiple recipients in a single transaction
     * @param dsts Array of recipient addresses
     * @param amounts Array of token amounts to mint (6 decimals)
     *
     * @dev Batch Processing:
     *      - Arrays must have matching lengths and be non-empty
     *      - All recipients must be allowlisted
     *      - Atomically mints to all recipients or reverts entirely
     *
     * @custom:access-control Only callable by contract owner
     * @custom:validation All addresses in dsts must be allowlisted
     * @custom:throws InvalidArgumentLengths if array lengths mismatch or empty
     * @custom:gas-optimization Batch processing reduces transaction costs
     * @custom:event Emits Mint and Transfer events for each recipient
     */
    function bulkMint(address[] calldata dsts, uint256[] calldata amounts) external {
        _requireAuth();
        _requireNotAccountingPaused();
        if (dsts.length != amounts.length || dsts.length == 0) revert InvalidArgumentLengths();

        uint256 length = dsts.length;

        for (uint256 i = 0; i < length; ++i) {
            _mint({to: dsts[i], amount: amounts[i]});
        }
    }

    /*//////////////////////////////////////////////////////////////
                        BURNING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns tokens from a specified address (admin function)
     * @param src Address from which tokens will be burned
     * @param amount Amount of tokens to burn (6 decimals)
     *
     * @dev Admin Burn Features:
     *      - Allows owner to burn tokens from any address
     *      - Does not require src to be msg.sender
     *      - Used for administrative corrections and redemption processing
     *
     * @custom:access-control Only callable by contract owner
     * @custom:throws Unauthorized if caller is not owner
     * @custom:event Emits AdminBurn(owner, src, amount) and Transfer(src, address(0), amount)
     */
    function adminBurn(address src, uint256 amount) external {
        _requireAuth();
        _requireNotAccountingPaused();

        _burn(src, amount);
        emit AdminBurn({burner: msg.sender, src: src, amount: amount});
    }

    /*//////////////////////////////////////////////////////////////
                    V5.1 COMPATIBILITY GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFundTokenV1
    function accountingPaused() external view returns (bool) {
        return isAccountingPaused();
    }

    /// @inheritdoc IFundTokenV1
    function allowlistV2() external view returns (address) {
        return allowlist();
    }

    /// @inheritdoc IFundTokenV1
    function redemptionContract() external view returns (address) {
        return getRedemptionContract();
    }

    /// @inheritdoc IFundTokenV1
    function supportedChainIds(uint256 chainId) external view returns (bool) {
        return isChainIdSupported(chainId);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the contract version for internal use
     * @return string The version constant
     */
    function _version() internal pure override returns (string memory) {
        return VERSION;
    }

    /**
     * @dev Returns the token name for internal use
     * @return string The token name from ERC20 storage
     */
    function _name() internal view override returns (string memory) {
        return super.name();
    }

    /**
     * @dev Returns the minimum acceptable oracle price
     * @return uint256 The minimum price floor ($7.00 in 6 decimals)
     */
    function _getMinimumAcceptablePrice() internal view override returns (uint256) {
        return MINIMUM_ACCEPTABLE_PRICE;
    }

    /*//////////////////////////////////////////////////////////////
                        AUTHORIZATION CHECKS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Requires caller to be contract owner
     * @custom:inheritance Resolves multi-inheritance conflict
     * @custom:throws Unauthorized if caller is not owner
     */
    function _requireAuth()
        internal
        view
        override(ERC20MetadataSettable, AccountingPausable, Bridgeable, Redeemable, Subscribable)
    {
        if (msg.sender != owner()) revert Unauthorized();
    }

    /**
     * @dev Requires address to be allowlisted
     * @param addr Address to check
     * @custom:inheritance Implements Bridgeable and Redeemable requirement
     * @custom:throws InsufficientPermissions if address is not allowlisted
     */
    function _requireAllowed(address addr) internal view override(Bridgeable, Redeemable) {
        if (!isAllowed(addr)) revert InsufficientPermissions();
    }

    /**
     * @dev Requires the global pause not to be engaged
     * @custom:inheritance Resolves multi-inheritance from PausableUpgradeable and Subscribable
     */
    function _requireNotPaused() internal view override(PausableUpgradeable, Subscribable) {
        super._requireNotPaused();
    }

    /**
     * @dev Requires the accounting pause not to be engaged (gates all mint/burn paths)
     * @custom:inheritance Resolves multi-inheritance from Bridgeable, Redeemable, and Subscribable
     * @custom:throws AccountingIsPaused if accounting is paused
     */
    function _requireNotAccountingPaused() internal view override(Bridgeable, Redeemable, Subscribable) {
        if (isAccountingPaused()) revert AccountingIsPaused();
    }

    /**
     * @dev Internal mint function with allowlist enforcement
     * @param to Recipient address (must be allowlisted)
     * @param amount Amount to mint
     * @custom:inheritance Resolves multi-inheritance for Subscribable and ERC20Upgradeable
     * @custom:security Enforces allowlist check on every mint path (admin, bulk, subscribe)
     */
    function _mint(address to, uint256 amount) internal override(ERC20Upgradeable, Subscribable) {
        _requireAllowed(to);
        super._mint(to, amount);
        emit Mint(msg.sender, to, amount);
    }

    /**
     * @dev Internal burn function
     * @param from Address to burn tokens from
     * @param amount Amount to burn
     * @custom:inheritance Resolves multi-inheritance for Bridgeable, Redeemable, and ERC20Upgradeable
     */
    function _burn(address from, uint256 amount) internal override(ERC20Upgradeable, Bridgeable, Redeemable) {
        super._burn(from, amount);
    }

    /**
     * @dev Internal approve function routing for multi-inheritance
     * @param owner Token owner granting approval
     * @param spender Address receiving approval
     * @param amount Amount approved
     * @custom:inheritance Routes through Permittable for EIP-2612 support
     */
    function _approve(address owner, address spender, uint256 amount) internal override(ERC20Upgradeable, Permittable) {
        super._approve(owner, spender, amount);
    }

    /// @inheritdoc ERC20MetadataSettable
    function setName(string calldata newName) public override(ERC20MetadataSettable, IFundTokenV1) {
        super.setName(newName);
    }

    /// @inheritdoc ERC20MetadataSettable
    function setSymbol(string calldata newSymbol) public override(ERC20MetadataSettable, IFundTokenV1) {
        super.setSymbol(newSymbol);
    }
}
