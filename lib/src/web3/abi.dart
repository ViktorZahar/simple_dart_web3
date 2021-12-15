const multiCallGetEthBalance = [
  {
    'constant': true,
    'inputs': [
      {'name': 'addr', 'type': 'address'}
    ],
    'name': 'getEthBalance',
    'outputs': [
      {'name': 'balance', 'type': 'uint256'}
    ],
    'payable': false,
    'stateMutability': 'view',
    'type': 'function'
  }
];

const multiCallGetEthDecimals = [
  {
    'constant': true,
    'inputs': [],
    'name': 'decimals',
    'outputs': [
      {'internalType': 'uint8', 'name': '', 'type': 'uint8'}
    ],
    'payable': false,
    'stateMutability': 'view',
    'type': 'function'
  }
];
