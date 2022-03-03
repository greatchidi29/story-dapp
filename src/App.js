import { useState, useEffect } from "react";
import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";

import Navbar from "./components/Navbar";
import Storyslot from "./components/Storyslot";
import storyslot from "./contracts/storyslot.abi.json";
import IERC20 from "./contracts/IERC.abi.json";

const ERC20_DECIMALS = 18;

const contractAddress = "0x2bc593C1C92F63AE7e4a727eE9DE1c09bD9Fe8D4";
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";

function App() {
  const [celoBalance, setCeloBalance] = useState(0);
  const [contract, setcontract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [cUSDBalance, setcUSDBalance] = useState(0);
  const [story, setStory] = useState([]);

  useEffect(() => {
    connect();
  }, []);

  useEffect(() => {
    if (contract) {
      getStories();
    }
  }, [contract]);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    } else {
      console.log("no kit");
    }
  }, [kit, address]);

  const connect = async () => {
    if (window.celo) {
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];

        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("Not connected");
    }
  };

  const getBalance = async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const celoBalance = balance.CELO.shiftedBy(-ERC20_DECIMALS).toFixed(2);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

      const contract = new kit.web3.eth.Contract(storyslot, contractAddress);
      setcontract(contract);
      setCeloBalance(celoBalance);
      setcUSDBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  };

  const getStories = async () => {
    try {
      const storyLength = await contract.methods.getStoryLength().call();
      const _stories = [];

      for (let index = 0; index < storyLength; index++) {
        let _story = new Promise(async (resolve, reject) => {
          let story = await contract.methods.getStory(index).call();
          resolve({
            index: index,
            owner: story[0],
            title: story[1],
            story: story[2],
            amount: story[3],
            likes: story[4],
            isSell: story[5],
            isPaid: story[6],
          });
        });
        _stories.push(_story);
      }
      const stories = await Promise.all(_stories);
      setStory(stories);
    } catch (error) {
      console.log(error);
    }
  };

  const createStory = async (_title, _story, _amount) => {
    try {
      await contract.methods
        .createStory(_title, _story, _amount)
        .send({ from: address });
    } catch (error) {
      console.log(error);
    }
    getStories();
  };

  const buyStory = async (_index, _amount) => {
    const cUSDContract = new kit.web3.eth.Contract(IERC20, cUSDContractAddress);

    try {
      const amount = new BigNumber(_amount)
        .shiftedBy(ERC20_DECIMALS)
        .toString();
      await cUSDContract.methods
        .approve(contractAddress, amount)
        .send({ from: address });
      await contract.methods.buyStory(_index).send({ from: address });
      getBalance();
      getStories();
    } catch (error) {
      console.log(error);
    }
  };
  const sellStory = async (index) => {
    try {
      await contract.methods.sellStory(index).send({ from: address });
    } catch (error) {
      console.log(error);
    }
    getStories();
  };

  const likeStory = async(_index)=>{
    try {
      await contract.methods.likeStory(_index).send({ from: address });
    } catch (error) {
      console.log(error);
    }
    getStories();
  }
  return (
    <div>
      <Navbar balance={cUSDBalance} />
      <Storyslot
        stories={story}
        createStory={createStory}
        buyStory={buyStory}
        address = {address}
        sellStory = {sellStory}
        likeStory = {likeStory}
      />
    </div>
  );
}

export default App;
