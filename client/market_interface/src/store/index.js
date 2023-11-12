import { createStore } from 'vuex'
import { connect } from "@argent/get-starknet";
import { CallData, Contract, getChecksumAddress,shortString } from "starknet";

export const market_contract_address = "0x043f0c669118286410b6e3f5dbc4159f162f21c229be06ebfad69d7e1b366a2b";
export const game_contract_address = "0x02a284ee5cc310ae2511ddd8f1a10b333cfd94279525737adb72c897f5d5d67b";
export const coin_contract_address = "0x022dfc81fef882f1588aa8ab4dc3151c5a16debc8e9fc9284be3ae301da15c35";

const decimal = 18;

import market_contract_abi from "./market_abi.json";
import game_contract_abi from "./game_abi.json";
import coin_contract_abi from "./coin_abi.json";


export default createStore({
    state: {
        wallet_address: "",
        provider: null,
        account: null,
        game_contract: null,
        coin_contract: null,
        market_contract: null,
        visibleConfirmPage: false,
        visibleGamePage: false,
        visiblePayPage: false,
        page: "BUY",
        queryData: null,
        orderInfo:null
    },
    getters: {},
    mutations: {
        setWalletAddress(state, value) {
            state.wallet_address = value;
        },
        setAccount(state, value) {
            state.account = value;
        },
        setProvider(state, value) {
            state.provider = value;
        },
        setMarketContract(state, value) {
            state.market_contract = value;
        },
        setCoinContract(state, value) {
            state.coin_contract = value;
        },
        setGameContract(state, value) {
            state.game_contract = value;
        },
        setVisibleConfirmPage(state, value) {
            state.visibleConfirmPage = value
        },
        setVisibleGamePage(state, value) {
            state.visibleGamePage = value
        },
        setVisiblePayPage(state, value) {
            state.visiblePayPage = value
        },
        setPage(state, value) {
            state.page = value
        },
        setOrderInfo(state, value) {
            state.orderInfo = value
        },
    },
    actions: {
        async connect_wallet(context) {
            const a = await connect({
                modalMode: "alwaysAsk",
                modalTheme: "dark",
                chainId: "SN_GOERLI"
            });
            let wallet_address = a.account.address;
            const provider = a.provider;
            const account = a.account;

            wallet_address = getChecksumAddress(wallet_address);


            context.commit("setWalletAddress", wallet_address);
            context.commit("setAccount", account);
            context.commit("setProvider", provider)

            const market_contract = new Contract(market_contract_abi, market_contract_address, context.state.account);
            const coin_contract = new Contract(coin_contract_abi, coin_contract_address, context.state.account);
            const game_contract = new Contract(game_contract_abi, game_contract_address, context.state.account);

            context.commit("setMarketContract", market_contract);
            context.commit("setCoinContract", coin_contract);
            context.commit("setGameContract", game_contract);


            setTimeout(async () => {
                const querydata = await context.dispatch("batch_query_equipment", 50)
                console.log(querydata)
            }, 1000);



        },
        async query_equipment(context, id) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                return await context.state.market_contract.query_equipment(id);
            } catch (e) {
                console.log(e);
            }
        },
        async batch_query_equipment(context, maxId) {
            const queryData = []

            if (context.state.account == null) {
                return;
            }

            function getEmptyObjectKey(obj) {
                for (let key in obj) {
                  if (JSON.stringify(obj[key]) === '{}') {
                    return key;
                  }
                }
              }

            try {
                await Promise.all(
                    Array.from({ length: maxId }, async (v, i) => {
                        try {
                            const e = await context.state.market_contract.query_equipment(i);
                            
                            queryData.push({
                                ...e,
                                nameString:shortString.decodeShortString(e.name),
                                stateString: getEmptyObjectKey(e.status.variant),
                                myOwn:e.publisher==this.state.wallet_address
                            })
                        } catch (error) {
                            // console.log(error)
                        }

                    })
                );


                this.state.queryData = queryData

                return queryData
            } catch (e) {
                console.log(e);
            }
        },
        async publish_equipment(context, { name, price }) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                let tx = await context.state.market_contract.publish_equipment(name, game_contract_address, price, coin_contract_address);
                return tx;
            } catch (e) {
                console.log(e);
            }
        },
        async buy_equipment(context, id) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                let tx = await context.state.market_contract.buy_equipment(id);
                return tx;
            } catch (e) {
                console.log(e);
            }
        },
        async confirm_finish(context, id) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                let tx = await context.state.market_contract.confirm_finish(id);

                return tx;
            } catch (e) {
                console.log(e);
            }
        },
        async rollback_purchase(context, id) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                let tx = await context.state.market_contract.rollback_purchase(id);
                return tx;
            } catch (e) {
                console.log(e);
            }
        },
        async unpublish_equipment(context, id) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            try {
                let tx = await context.state.market_contract.unpublish_equipment(id);
                return tx;
            } catch (e) {
                console.log(e);
            }
        },
        async approve(context, price) {
            try {
                await this.state.coin_contract.approve(market_contract_address, price);
            } catch (e) {
                console.log(e);
            }
        },
        async multicall(context, { price, id }) {
            if (context.state.account == null) {
                await context.dispatch('connect_wallet');
                return;
            }
            // let approve = {
            //     contractAddress: coin_contract_address,
            //     entrypoint: "approve",
            //     calldata:
            //         CallData.compile({
            //             spender: market_contract_address,
            //             amount:price
            //         })
            // };
            // let buy = {
            //     contractAddress: market_contract_address,
            //     entrypoint: "buy_equipment",
            //     calldata:
            //         CallData.compile({
            //             amount: {type: 'struct', low: id, high: '0'},
            //         })
            // }

            // const tx = await context.state.account.execute(
            //     [approve]
            // )
            //
            // const receipt = await context.state.provider.waitForTransaction(tx.transaction_hash);
            // console.log(receipt);
        }
    },
    modules: {}
})
