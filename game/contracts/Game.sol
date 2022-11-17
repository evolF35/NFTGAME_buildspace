
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Game {

    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint regenrate;
    }
    CharacterAttributes[] defaultCharacters;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        uint[] memory characterRegenRate
        )
        {

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
    }


}