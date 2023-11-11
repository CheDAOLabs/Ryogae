<template>
  <div class="alertContent">
    <div class="center">
      <div class="imgbox"><img src="images/im1.png" alt=""></div>
      <input type="text" class="words" placeholder="QUANTITY">
      <input type="text" class="words" placeholder="PRICE">
      <div class="total">TOTAL:00,000.00</div>
      <button class="btn" @click="onClickClose">CONFIRM</button>
    </div>
  </div>
</template>

<script>
import {mapActions, mapMutations} from "vuex";

export default {
  name: "ConfirmModal",
  methods: {
    ...mapActions([
      'connect_wallet',
      'query_equipment',
      'publish_equipment', 'buy_equipment', 'confirm_finish', 'rollback_purchase', 'unpublish_equipment'
    ]),
    ...mapMutations(['setVisibleConfirmPage', 'setVisibleGamePage', 'setVisiblePayPage']),
    onClickClose() {
      this.setVisibleConfirmPage(false);
    }
  }
}
</script>

<style scoped>

</style>