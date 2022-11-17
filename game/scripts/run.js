

const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('Game');
    const gameContract = await gameContractFactory.deploy(
    ["Mozart", "Jacob_Fuger", "Larry_Ellison"],       // Names
    ["https://i.imgur.com/pKd5Sdk.png", // Images
    "https://i.imgur.com/xVu4vFL.png", 
    "https://i.imgur.com/WMB6g9u.png"],
    [100, 200, 300],                    // HP values
    [100, 50, 25], //Attack
    [10,20,30]  //regen
    );
    await gameContract.deployed();

    console.log("Contract deployed to:", gameContract.address);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } 
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();