<template>
  <div id="app">
        <div class="card-header">
          <span style="color: rgb(237, 10, 10);font-size: 30px">Ryogae</span>
          <el-button class="button" plain type="primary" @click="connect">
            {{
              wallet_address == null ? "Connect Wallet" : wallet_address.toString().substr(0, 10) + "..." + wallet_address.toString().substr(wallet_address.length - 4, 4)
            }}
          </el-button>
        </div>

      <div style="color: rgb(237, 10, 10);font-size: 24px;font-family: VT323;margin-top: 10px"> {{ name }}</div>
      <div style="margin-top: 10px">
        <el-button type="danger" plain @click="buy">buy</el-button>
      </div>
    <div>

    <button style="color: white;font-size: 24px;font-family: VT323;margin-top: 10px" @click="showForm = true">add product</button>

    <div v-if="showForm">
      <form @submit.prevent="handleSubmit">
        <label>
          price:
          <input v-model.number="price">
        </label>

        <label>
          quantity:  
          <input v-model.number="quantity">
        </label>

        <el-button type="danger" plain @click="submit">submit</el-button>
      </form>
    </div>
  </div>
  </div>
</template>

<script>
import {ElMessage} from 'element-plus'
import { constants, Provider} from "starknet";
import {connect} from "@argent/get-starknet"
import {useRoute} from 'vue-router';

//const abi = [];
//const address = "";

export default {
  data() {
    return {
      showForm: false,
      price: null,
      quantity: null
    }
  },
  handleSubmit() {
    const product = {
      price: this.price, 
      quantity: this.quantity
    }

    return this.addProduct(product)  
    .then(() => {
      this.showForm = false
    })
  },
  addProduct(product) {
    console.log(product);

    return new Promise((resolve) => {    
      resolve()
    })
  },
  name: 'App',
  components: {
    // HelloWorld
  },
  mounted() {
    this.provider = new Provider({sequencer: {network: constants.NetworkName.SN_GOERLI}});
    console.log("provider", this.provider);

    const route = useRoute();
    console.log("route", route);
    const token_id = route.params.id;
    console.log("token_id", token_id)
    if (token_id) {
      this.token_id = token_id;
    }
  },
  methods: {
    async buy() {
      if (this.wallet_address === null || this.wallet_address === '' || this.wallet_address === undefined) {
        ElMessage({
          message: 'Please connect your wallet first.',
          type: 'error',
        })
        return;
      }

      console.log(this.wallet_address + "   buy");

    },
    async connect() {
      const a = await connect({
        modalMode:"alwaysAsk",
        modalTheme:"dark",
        chainId:"SN_GOERLI"
      });
      console.log(a.account);
      this.wallet_address = a.account.address;
      console.log(this.wallet_address)
      this.provider = a.provider;
      this.account = a.account;
    },
    async submit() {
        console.log("submit");
    }
  }
}
</script>


<style>

body {
  margin: 0;
}

#app {
  text-align: center;
  height: 100vh;
  margin: 0;
  overflow: hidden;
  background-color: azure;
}

@font-face {
  font-family: 'VT323';
  src: url('./VT323-Regular.ttf');
  font-weight: normal;
  font-style: normal;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
} 

</style>
