<template>
  <div class="alertContent">
    <div class="mask" @click="onClickClose"></div>
    <div class="center" v-loading="loading">
      <div class="imgbox"><img src="images/im1.png" alt=""></div>
      <input v-if="order" type="text" class="words" placeholder="NAME" :value="decodeShortString(order.name)" disabled>
      <input v-if="order" type="text" class="words" placeholder="PRICE" :value="order.price" disabled>
      <button class="btn" @click="onClickConfirm">CONFIRM</button>
    </div>
  </div>
</template>

<script>
import {mapActions, mapMutations} from "vuex";
import {shortString} from "starknet";

const order_id = "0x07";

export default {
  name: "ConfirmModal",
  data() {
    return {
      loading: true,
      order: null
    }
  },
  async mounted() {
    this.loading = true;
    try {
      let order = await this.query_equipment(order_id);
      console.log("order:", order);
      this.order = order;
      this.loading = false;
    } catch (e) {
      console.error(e);
      this.setVisibleConfirmPage(false);
    }
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
    async onClickConfirm() {
      await this.confirm_finish(order_id);
    },
    decodeShortString(str) {
      return shortString.decodeShortString(str);
    }
  }
}
</script>

<style scoped>

</style>