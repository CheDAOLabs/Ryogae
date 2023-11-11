import {createStore} from 'vuex'
import {connect} from "@argent/get-starknet";
import {Contract, getChecksumAddress} from "starknet";

const market_contract_address = "0x076c2c12b6cd07f561c2b8f3578a705528acd9a96155a9841647f054bde79133";
import contract_abi from "./market_abi.json";


export default createStore({
    state: {
        wallet_address: "",
        provider: null,
        account: null,
        contract: null,
        visibleConfirmPage: false,
        visibleGamePage: false,
        visiblePayPage: false
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
        setContract(state, value) {
            state.contract = value
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

            const contract = new Contract(contract_abi, market_contract_address, context.state.account);

            context.commit("setContract", contract)


        },
        async query_equipment(context, id) {
            return await context.state.contract.query_equipment(id);
        },
        async publish_equipment(context, {name, game, price, coin_address}) {
            let tx = await context.state.contract.publish_equipment(name, game, price, coin_address);
            return tx;
        },
        async buy_equipment(context, id) {
            let tx = await context.state.contract.buy_equipment(id);
            return tx;
        },
        async confirm_finish(context, id) {
            let tx = await context.state.contract.confirm_finish(id);
            return tx;
        },
        async rollback_purchase(context, id) {
            let tx = await context.state.contract.rollback_purchase(id);
            return tx;
        },
        async unpublish_equipment(context, id) {
            let tx = await context.state.contract.unpublish_equipment(id);
            return tx;
        }
    },
    modules: {}
})
