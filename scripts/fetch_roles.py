"""Who holds which role right now, from RoleGranted/RoleRevoked and SetOperator logs.

Only the holder TYPE is saved (Safe threshold/signers, timelock delay, single key, other contract),
never the address, except for public protocol contracts. Output: data/raw/tbill_roles.json.
"""
import subprocess

from common import RPC_URL_STATE, get_logs, rpc, save, PUBLIC_ADDRESSES
from fetch_events import addr, topic

START = 16_000_000  # earlier than the vault so constructor-time role grants are included
from fetch_state import holder_type

T = "0xdd50C053C096CB04A3e3362E2b622529EC5f2e8a"
CONTRACTS = {"oracle": "0xCe9a6626Eb99eaeA829D7fA613d5D0A2eaE45F40",
             "controller": "0x377de6729507Bb0E56E0AAC666bd8522E4A3fe41",
             "vault_owner_timelock": "0x6E8559Afd41f8f9971828AA8B0C25b65cA6a5567"}
ROLE_NAMES = ["OPERATOR_ROLE", "PROPOSER_ROLE", "EXECUTOR_ROLE", "CANCELLER_ROLE", "TIMELOCK_ADMIN_ROLE"]


def role_hash(name):
    return subprocess.run(["cast", "keccak", name], capture_output=True, text=True).stdout.strip()


def active_holders(contract, head):
    """Replay Granted/Revoked logs in order and return {role name: set of addresses}."""
    names = {role_hash(n): n for n in ROLE_NAMES}
    names["0x" + "0" * 64] = "DEFAULT_ADMIN_ROLE"
    granted = topic("RoleGranted(bytes32,address,address)")
    revoked = topic("RoleRevoked(bytes32,address,address)")
    logs = get_logs(contract, [[granted, revoked]], START, head)
    logs.sort(key=lambda l: (int(l["blockNumber"], 16), int(l["logIndex"], 16)))
    holders = {}
    for l in logs:
        role = names.get(l["topics"][1], l["topics"][1][:10])
        who = addr(l["topics"][2])
        s = holders.setdefault(role, set())
        s.add(who) if l["topics"][0] == granted else s.discard(who)
    return holders


def vault_operators(head):
    """Vault SetOperator(address,bool): last status per operator address."""
    sig = topic("SetOperator(address,bool)")
    status = {}
    for l in sorted(get_logs(T, [sig], START, head), key=lambda l: (int(l["blockNumber"], 16), int(l["logIndex"], 16))):
        status[addr("0x" + l["data"][2:66])] = int(l["data"][66:130], 16) == 1
    return {a for a, on in status.items() if on}


def describe(addresses):
    out = []
    for a in sorted(addresses):
        info = holder_type(a)
        info["public_name"] = PUBLIC_ADDRESSES.get(a.lower())
        out.append(info)
    return out


ADMIN_EVENTS = ["BurnFrom(address,uint256)", "MintTo(address,uint256)", "ReIssue(address,address,uint256)",
                "SetRedemption(address)", "SetKycManager(address)", "SetController(address)",
                "SetTBillPriceFeed(address)", "Cancel(uint256,uint256)"]


def admin_event_counts(head):
    """How often each admin power has been used on the vault since deployment (counts only)."""
    return {sig: len(get_logs(T, [topic(sig)], 18_376_020, head)) for sig in ADMIN_EVENTS}


def main():
    head = int(rpc("eth_blockNumber", [], RPC_URL_STATE), 16)
    result = {"head_block": head, "roles": {}, "admin_event_counts": admin_event_counts(head)}
    for label, contract in CONTRACTS.items():
        for role, addrs in active_holders(contract, head).items():
            result["roles"][f"{label}:{role}"] = describe(addrs)
    result["roles"]["vault:operators (SetOperator)"] = describe(vault_operators(head))
    save("tbill_roles.json", result)
    for k, v in result["roles"].items():
        print(k, [(x["type"], x.get("threshold"), x.get("signers")) for x in v])


if __name__ == "__main__":
    main()
