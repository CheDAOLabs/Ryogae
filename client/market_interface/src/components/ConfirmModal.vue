<template>
  <div class="alertContent type2">
    <div class="list">
<!--      <div class="mask" @click="onClickClose"></div>-->
      <div class="center" v-for="item in getMyOrder()" :key="item.title">
        <div class="imgbox"><img src="images/im1.png" alt=""></div>
        <input type="text" class="words" placeholder="NAME" :value="decodeShortString(item.name)" disabled>
        <input type="text" class="words" placeholder="PRICE" :value="item.price" disabled>
        <input type="text" class="words" placeholder="STATE" :value="item.stateString" disabled>
        <button class="btn" @click="onClickConfirm(item)">CONFIRM</button>
      </div>
    </div>
  </div>
</template>

<script>
import {mapActions, mapMutations, mapState} from "vuex";
import {shortString} from "starknet";

export default {
  name: "ConfirmModal",
  data() {
    return {
      loading: true,
      // order: null,
      // items:[],
      my_address: "",
    }
  },
  computed: {
    ...mapState([
      'orderInfo', 'queryData', 'wallet_address'
    ]),
  },
  async mounted() {
    // this.order = this.orderInfo;
    // this.items = this.queryData;
    // console.log(this.items)
    this.my_address = this.wallet_address;
  },
  methods: {
    ...mapActions([
      'connect_wallet',
      'query_equipment',
      'publish_equipment', 'buy_equipment', 'confirm_finish', 'rollback_purchase', 'unpublish_equipment'
    ]),
    ...mapMutations(['setVisibleConfirmPage', 'setVisibleGamePage', 'setVisiblePayPage']),
    onClickClose() {
      this.setVisibleConfirmPage(false);
    },
    async onClickConfirm(item) {
      console.log(item)
      await this.confirm_finish(item.id);
    },
    decodeShortString(str) {
      return shortString.decodeShortString(str);
    },
    getMyOrder() {
      if (!this.queryData) {
        return;
      }
      let res = [];
      for (let i = 0; i < this.queryData.length; i++) {
        let item = this.queryData[i];
        if (item.stateString === 'Unpurchasable' && item.myOwn) {
          res.push(item)
        }
      }
      // console.log(res);
      return res;
    }
  }
}
</script>

<style scoped>

</style>