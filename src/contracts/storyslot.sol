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
        bool isSell;
        bool isPaid;
    }
    mapping (uint256 => Story) stories;

    // using map to assign if an address has already like a story or not
    // true means -> address has liked the story with a particular story_id
    // false (default) -> address has not-liked or disliked(had liked before) the story with a particular story_id
    mapping (address => mapping(uint256 => bool)) storyliked; 

    uint256 storyLength = 0;

    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

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
            false,
            false
        );

        storyLength++;
    }

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
        Story storage story = stories[_index];
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

    function likeOrDislikeStory(uint256 _index) public {
        // Owner should not be allowed to like its own story and increase the price arbitarily
        require(
            msg.sender != stories[_index].owner, // prevents owner liking its own story
            "Owner cannot like its own story."
        );
        // a single user cannot like the same story multiple times and increase the price
        if (storyliked[msg.sender][_index] == false) {
            stories[_index].likes++;
            storyliked[msg.sender][_index] = true; // setting the value true for the current user. The current user has liked this story.
            if (stories[_index].likes % 2 == 0) {
                stories[_index].amount++; // updaing the amount
            }
        }
        else {
            stories[_index].likes--;
            storyliked[msg.sender][_index] = false; // setting the value to false for current user. The current user has disliked this story.
            if (stories[_index].likes % 2 != 0 )
                stories[_index].amount--; // decrementing the amount of story based on the current number of likes
        }
    }

    function buyStory(uint256 _index) public payable {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                stories[_index].owner,
                stories[_index].amount
            ),
            "Transaction could not be performed"
        );
        stories[_index].owner = payable(msg.sender);
        stories[_index].isPaid = true;
    }

    function sellStory(uint256 _index) public {
        require(stories[_index].isPaid == true, "Story has not been bought");
        stories[_index].isPaid = false;
    }

    function getStoryLength() public view returns (uint256) {
        return (storyLength);
    }
}