// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract StorySlot {
    struct Story {
        address payable owner;
        string title;
        string storyslot;
        uint256 amount;
        uint256 likes;
        bool forSale;
        bool isSell;
        bool isPaid;
    }

    //Mapping to store all the stories
    mapping(uint256 => Story) stories;

    //A mapping to ensure that one can like a story only once
    mapping(uint => mapping(address => bool) ) hasLiked;
    uint256 storyLength = 0;

    //Events to give relevant data to the user
    event newStory(address indexed poster, string title, uint index);

    event newLike(address indexed poster, uint index, address indexed liker);

    event storyBought(address indexed poster, uint index, address indexed buyer);

    event buyerInterest(address indexed poster, uint index, address indexed buyer);

    address internal constant cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;


    //Modifier to ensure that only the owner can acces the function
    modifier onlyOwner(uint _index){
        require (stories[_index].owner == msg.sender, "Only the owner can access this function");
        _;
    }

    //Function to add your story
    function createStory(
        string memory _title,
        string memory _storyslot,
        uint256 _amount
    ) public {
        stories[storyLength] = Story(
            payable(msg.sender),
            _title,
            _storyslot,
            _amount,
            0,
            true,
            false,
            false
        );

        emit newStory(msg.sender, _title, storyLength);
        storyLength++;
    }

    //Read story
    function getStory(uint256 _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        Story memory story = stories[_index];
        return (
            story.owner,
            story.title,
            story.storyslot,
            story.amount,
            story.likes,
            story.isSell,
            story.isPaid
        );
    }

    function likeStory(uint256 _index) public {
        //Condition to ensure that the poster can't like his own story
        require(msg.sender != stories[_index].owner, "Story cannot be liked by the owner himself");
        //Condition to ensure that one user can like one story only once
        require(
            hasLiked[_index][msg.sender] == false,
            "A user can like a story only once"
        );
        stories[_index].likes++;
        if (stories[_index].likes % 2 == 0) {
            stories[_index].amount++;
        }
        hasLiked[_index][msg.sender] = true;

        emit newLike(stories[_index].owner, _index, msg.sender);
    }

    //Function to put story to sale
    function putStoryToSale(uint _index)  public onlyOwner(_index){
        stories[_index].forSale = true;
    }

    //Function to take the story out of sale
    function takeStoryOutOfSale(uint _index) public onlyOwner(_index){
        stories[_index].forSale = false;
    }

    function buyStory(uint256 _index) public payable {

        //Checks if the story is for sale, if not the owner of the story will be notified that a buyer is interested
        require(stories[_index].forSale == true, "The story is not for sale currently, the user will be notified by your approach");
        emit buyerInterest(stories[_index].owner, _index, msg.sender);
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                stories[_index].owner,
                stories[_index].amount
            ),
            "Transaction could not be performed"
        );
        emit storyBought(stories[_index].owner, _index, msg.sender);

        stories[_index].owner = payable(msg.sender);
        stories[_index].isPaid = true;

    }

    function sellStory(uint256 _index) public {
        require(stories[_index].isPaid == true, "Story has not been bought");
        stories[_index].isPaid = false;
    }

    //Function to reSell the story to higher price, but comes with the cost of lossing the likes
    function reSellToHigherPrice(uint _index,uint _amount) public onlyOwner(_index){
        //Resets the number of likes it has
        stories[_index].likes = 0;
        stories[_index].amount = _amount;
    }

//Function to return the total amount of stories
    function getStoryLength() public view returns (uint256) {
        return (storyLength);
    }
}

