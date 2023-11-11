<template>
  <div class="alertContent">
    <div class="mask" @click="onClickClose"></div>
    <div class="center">
      <div class="imgbox"><img src="images/im1.png" alt=""></div>
      <input type="text" class="words" placeholder="NAME" v-model="name">
      <input type="number" class="words" placeholder="PRICE" v-model="price">
      <!--      <div class="total">TOTAL:00,000.00</div>-->
      <button class="btn" @click="onClickSubmit">SUBMIT</button>
    </div>
  </div>
</template>

<script>
import {mapActions, mapMutations} from "vuex";

export default {
  name: "GamesPage",
  data() {
    return {
      name: "",
      price: null,
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
      this.setVisibleGamePage(false);
    },
    async onClickSubmit() {
      await this.publish_equipment({name: this.name, price: this.price});
    }
  }
}
</script>

<style scoped>

</style>