pragma solidity ^0.5.0;

contract blockchainMessage {
	// mapping (for storing values)
	mapping (string => address) private _usernameToAddress; // get address from username
	mapping (address => string) private _addressToUsername; // get username from address

	mapping (address => bool) private _isAddressUsed; // check wether an address has used contract or not
	mapping (string => bool) private _isUsernameUsed; // if an username is already used
	
	mapping (address => mapping (address => bool)) private _allowances; // "delegate" allowance, used for preventing to use the same key everywhere
	mapping (address => mapping (uint256 => string)) private _messages; // messages of a specific user
	mapping (address => uint256) private _nonces; // nonce of an account's message
	
	mapping (uint256 => string) _allMessages; // all the messages
	mapping (uint256 => string) _globalMessageSender; // sender of a global message
	
	// variables
	uint256 _globalNonce = 0; // nonce to use for the next message
	
	
	// events
	event SendMessage(address _sender, address _recipient, uint256 _nonce);
	
	
	function bindUsername(address _address, string memory _username) public returns (bool) {
		require((_address == msg.sender)||(_allowances[msg.sender][_address])); // address should have permission
		require(!(_isUsernameUsed[_username])); // username shouldn't be already used
		if (_isAddressUsed[_address]) {
			_isUsernameUsed[_addressToUsername[_address]] = false; // sets OLD username as unused
		}
		_usernameToAddress[_username] = _address; // binds username to address
		_addressToUsername[_address] = _username; // binds address to username
		_isUsernameUsed[_username] = true; // marks new username as used
		_isAddressUsed[_address] = true; // marks address as used
		return true;
	}
	
	function _publish(address _sender, string memory _message) internal {
		_nonces[_sender] += 1;
		_globalNonce += 1;
		_messages[_sender][_nonces[_sender]] = _message;
		_allMessages[_globalNonce] = _message;
	}
	
	function publish(string memory _message) public returns (bool) {
		_publish(msg.sender, _message);
		return true;
	}
	
	function publishFrom(address _sender, string memory _message) public returns (bool) {
		require(_allowances[msg.sender][_sender]);
		_publish(_sender, _message);
		return true;
	}
	
	function getCurrentNonce(address _sender) public view returns (uint256) {
		return _nonces[_sender];
	}
	
	function getCurrentGlobalNonce() public view returns (uint256) {
		return _globalNonce;
	}
	
	function getMessage(address _sender, uint256 _nonce) public view returns (string memory) {
		return _messages[_sender][_nonce];
	}
	
	function getLastMessage(address _sender) public view returns (string memory) {
		return _messages[_sender][_nonces[_sender]];
	}
	
	function getLastGlobalMessage() public view returns (string memory) {
		return _allMessages[_globalNonce];
	}
	
	function getGlobalMessage(uint256 _nonce) public view returns (string memory) {
		return _allMessages[_nonce];
	}
	
	function addressToUsername(address _address) public view returns (string memory){
		return _addressToUsername[_address];
	}
	
	function usernameToAddress(string memory _username) public view returns (address) {
		return _usernameToAddress[_username];
	}
}
