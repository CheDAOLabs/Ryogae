<template>
  <div class="alertContent">
    <div class="mask" @click="onClickClose"></div>
    <div class="center" v-loading="loading">
      <div v-if="order" type="text" class=""  style="color: white;position: absolute;left: 20px;top: 20px;font-size: 20px;">#{{ order.id }}</div>

      <div class="imgbox"><img src="images/im1.png" alt=""></div>

      <input v-if="order" type="text" class="words" placeholder="NAME" :value="decodeShortString(order.name)" disabled>
      <input v-if="order" type="text" class="words" placeholder="PRICE" :value="order.price" disabled>
      <input v-if="order" type="text" class="words" placeholder="STATE" :value="order.stateString" disabled>
      <!--      <div class="total">TOTAL:00,000.00</div>-->

      <button class="btn" @click="OnClickApprove">APPROVE</button>

      <button class="btn" @click="onClickPurchase" style="margin-top: 10px">PURCHASE</button>
    </div>
  </div>
</template>

<script>
import {mapActions, mapMutations,mapState} from "vuex";
import {shortString} from "starknet";

// const order_id = "13";

export default {
  name: "PayPage",
  data() {
    return {
      loading: false,
      order: null
    }
  },
  computed: {
    ...mapState([
      'orderInfo'
    ]),
  },
  async mounted() {
    this.order = this.orderInfo;

  
  },
  methods: {
    ...mapActions([
      'connect_wallet',
      'query_equipment',
      'publish_equipment', 'buy_equipment', 'confirm_finish', 'rollback_purchase', 'unpublish_equipment',
      'multicall', 'approve'
    ]),
    ...mapMutations(['setVisibleConfirmPage', 'setVisibleGamePage', 'setVisiblePayPage']),
    onClickClose() {
      this.setVisiblePayPage(false);
    },
    async onClickPurchase() {
      await this.buy_equipment(this.order.id);
    },
    async OnClickApprove() {
      await this.approve(this.order.price);
    },
    decodeShortString(str) {
      return shortString.decodeShortString(str);
    }
  }
}
</script>

<style scoped>

</style>