import { Interface } from '@ethersproject/abi'
import Web3 from "web3";

interface Call {
    address: string
    abi: any[]
    name: string
    params: any[]
}

export class Web3Wrapper {
    netId: number
    multicallAddress: string
    rcpAddress: string
    web3: Web3
    constructor(netId: number, multicallAddress: string, rcpAddress: string) {
        this.netId = netId
        this.multicallAddress = multicallAddress
        this.rcpAddress = rcpAddress
        this.web3 = new Web3(this.rcpAddress)
    }

    async multicall(calls: Call[]): Promise<any[]> {
        const startTime = Date.now()
        const contract = new this.web3.eth.Contract([{ "constant": true, "inputs": [{ "components": [{ "name": "target", "type": "address" }, { "name": "callData", "type": "bytes" }], "name": "calls", "type": "tuple[]" }], "name": "aggregate", "outputs": [{ "name": "blockNumber", "type": "uint256" }, { "name": "returnData", "type": "bytes[]" }], "payable": false, "stateMutability": "view", "type": "function" }], this.multicallAddress)

        const callData = []
        calls.forEach((call) => {
            const itf = new Interface(call.abi)
            callData.push([call.address.toLowerCase(), itf.encodeFunctionData(call.name, call.params)])
        })
        const { returnData } = await contract.methods.aggregate(callData).call()
        // console.log(Date.now() - startTime + 'ms ' + this.netId + ' ' + calls[0].address + '.' + calls[0].name + ' ' + '=' + calls.length)
        return returnData.map((data, i) => {
            const call = calls[i]
            const itf = new Interface(call.abi)
            return itf.decodeFunctionResult(call.name, data)
        })
    }
}


window['Web3Wrapper'] = Web3Wrapper