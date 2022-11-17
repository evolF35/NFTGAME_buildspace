
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Libraries/Base64.sol";


contract Game is ERC721 {

    uint randNonce = 0; // this is used to help ensure that the algorithm has different inputs every time

    function randomInt(uint _modulus) internal returns(uint){
        randNonce++;
        return( uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,
        randNonce)))% _modulus);
    }

    event CharachterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);
    event Regened(address sender, uint newPlayerHp);


    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint regenrate;
    }

    struct Boss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    Boss public BigBoss;

    mapping (address => uint256) public lastRefuel;

    CharacterAttributes[] defaultCharacters;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    mapping (uint256 => CharacterAttributes) public nftHolderAttributes;

    mapping (address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        uint[] memory characterRegenRate,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
        ) 
        ERC721("Teradyne","COMP")
        {

            BigBoss = Boss({
                name: bossName,
                imageURI: bossImageURI,
                hp: bossHp,
                maxHp: bossHp,
                attackDamage: bossAttackDamage
            });

        console.log("Done initializing boss %s w/ HP %s, img %s", BigBoss.name, BigBoss.hp, BigBoss.imageURI);


        for(uint i = 0; i < characterNames.length; i += 1){
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i],
                regenrate: characterRegenRate[i]
            }));
            

        CharacterAttributes memory c = defaultCharacters[i];
        console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }

        _tokenIds.increment();
        }

    function mintCharacterNFT(uint _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender,newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            regenrate: defaultCharacters[_characterIndex].regenrate

        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();
        emit CharachterNFTMinted(msg.sender,newItemId,_characterIndex);
        lastRefuel[msg.sender] = block.timestamp;


    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
        string memory strRegenRate = Strings.toString(charAttributes.regenrate);

        string memory json = Base64.encode(
    abi.encodePacked(
      '{"name": "',
      charAttributes.name,
      ' -- NFT #: ',
      Strings.toString(_tokenId),
      '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
      charAttributes.imageURI,
      '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
      strAttackDamage,'}, {"trait_type": "RegenRate", "value": ',strRegenRate,'} ]}'
            )
        );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,",json)
    );

    return(output);

    }


    function attackBoss() public {

        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("\nPlayer w/ character %s about to attack. Has %s RG", player.name, player.regenrate);

        console.log("Boss %s has %s HP and %s AD", BigBoss.name, BigBoss.hp, BigBoss.attackDamage);

        require(
            player.hp > 0,
            "You are dead"
        );

        require(
            BigBoss.hp > 0,
            "big dawg is dead already"
        );


        if (BigBoss.hp < player.attackDamage){
            BigBoss.hp = 0;
        }
        else{
            BigBoss.hp = BigBoss.hp - player.attackDamage;
        }

        if (player.hp < BigBoss.attackDamage){
            player.hp = 0;
        }
        else{
            player.hp = player.hp - BigBoss.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", BigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);

        emit AttackComplete(msg.sender,BigBoss.hp,player.hp);
    }


    function checkIfUserHasNFT() public view returns (CharacterAttributes memory){

        uint256 userNFTtokenId = nftHolders[msg.sender];

        if (userNFTtokenId > 0){
            return (nftHolderAttributes[userNFTtokenId]);
        }
        else {
            CharacterAttributes memory emptyStruct;
            return (emptyStruct);
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory){
        return( defaultCharacters);
    }

    function getBoss() public view returns (Boss memory){
        return(BigBoss);
    }


    function refuel() public {

        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

    require(
            player.hp > 0,
            "You are dead"
    );
    require(
        player.hp < player.maxHp,
        "you are full"
    );

        require(lastRefuel[msg.sender]+ 1 minutes < block.timestamp,"waIT");
        lastRefuel[msg.sender] = block.timestamp;

        if(player.hp + player.regenrate >= player.maxHp){
            player.hp = player.maxHp;
        }
        else {
            player.hp = player.hp + player.regenrate;
        }

        emit Regened(msg.sender,player.hp);

    }

    
}