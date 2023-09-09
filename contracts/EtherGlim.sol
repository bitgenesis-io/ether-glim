/**
*
* EtherGlim Disclaimer:
*
* EtherGlim is an experimental token and smart contract platform. Use of this platform is at your own risk, and it is provided "as is" without any express or implied warranties, including but not limited to, merchantability, fitness for a particular purpose, or non-infringement.
*
* Limitation of Liability:
*
* EtherGlim, BitGenesis, and all associated parties will not be liable for any losses, damages, or claims of any nature whatsoever arising from or in connection with the use, interaction, or deployment of the EtherGlim smart contracts, tokens, or associated services, regardless of the form of action.
*
* Regulatory Compliance:
*
* The EtherGlim project does not claim to be in compliance with any jurisdictional laws or regulations and is not responsible for ensuring user compliance with the same. Users are encouraged to consult legal experts to understand their regulatory obligations while interacting with the EtherGlim token and smart contracts.
*
* No Financial Advice:
*
* The EtherGlim token is not intended to be an investment, financial instrument, or any form of financial advice. The token is experimental in nature and is solely for entertainment and/or educational purposes.
*
*
*   ____ _____ _______ _____ ______ _   _ ______  _____ _____  _____
* |  _ \_   _|__   __/ ____|  ____| \ | |  ____|/ ____|_   _|/ ____|
* | |_) || |    | | | |  __| |__  |  \| | |__  | (___   | | | (___
* |  _ < | |    | | | | |_ |  __| | . ` |  __|  \___ \  | |  \___ \
* | |_) || |_   | | | |__| | |____| |\  | |____ ____) |_| |_ ____) |
* |____/_____|  |_|  \_____|______|_| \_|______|_____/|_____|_____/
*/

pragma solidity ^0.8.0;

// Importing OpenZeppelin's ERC20 and Ownable contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// GlimToken contract inheriting from ERC20 and Ownable contracts
contract GlimToken is ERC20, Ownable {
    // Public variable to hold the minter's address
    address public minter;

    // Mapping to identify Uniswap Pairs
    mapping(address => bool) public isUniswapPair;

    // Constructor to initialize token details
    constructor() ERC20("Glim", "GLM") {}

    // Custom modifier to restrict function access
    modifier onlyMinterOrOwner() {
        require(msg.sender == minter || msg.sender == owner(), "Only minter or owner can call this function");
        _;
    }

    // Internal function to check if an address is a contract
    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    // Function to set minter address
    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    // Overriding the _transfer function to add custom logic
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        // Conditions to prevent contracts from receiving tokens, except for owner and minter
        if (sender != owner() && sender != minter) {
            require(!isContract(recipient), "Tokens can only be transferred to an EOA");
        }
        super._transfer(sender, recipient, amount);
    }

    // Function to mint new tokens
    function mint(address to, uint256 amount) external onlyMinterOrOwner {
        _mint(to, amount);
    }
}

// GlimMinter contract, responsible for minting GlimTokens
contract GlimMinter is Ownable {
    // Token contract instance
    GlimToken public token;

    // Price mapping for each token amount
    mapping(uint256 => uint256) public priceForAmount;

    // Event to log token claims
    event TokensClaimed(address indexed user, uint256 amount, uint256 cost);

    // Event to log price updates
    event PriceUpdated(uint256 amount, uint256 newPrice);

    // Constructor to initialize GlimToken
    constructor(address _token) {
        token = GlimToken(_token);
        token.setMinter(address(this));

        // Setting initial prices
        priceForAmount[1] = 0.01 ether;
        priceForAmount[10] = 0.02 ether;
        priceForAmount[100] = 0.03 ether;
        priceForAmount[1000] = 0.05 ether;
    }

    // Function to update price for different token amounts
    function updatePrice(uint256 amount, uint256 newPrice) external onlyOwner {
        require(amount > 0, "Amount should be greater than 0");
        require(newPrice > 0, "New price should be greater than 0");

        // Updating the price
        priceForAmount[amount] = newPrice;

        emit PriceUpdated(amount, newPrice);
    }

    // Function to claim tokens
    function claimTokens(uint256 amount) external payable {
        // Validation checks
        require(priceForAmount[amount] > 0, "Invalid token amount");
        require(msg.value == priceForAmount[amount], "Incorrect Ether value");

        // Minting and sending tokens to the claimant
        token.mint(msg.sender, amount);

        // Logging the event
        emit TokensClaimed(msg.sender, amount, msg.value);
    }
}
