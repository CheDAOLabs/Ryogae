<template>
  <div>
    <div class="test">
      <Button @click="connect_wallet">{{ wallet_address ? wallet_address : "Connect Wallet" }}</Button>
      <Button @click="onClickQueryEquipment">QueryEquipment</Button>
      <Button @click="onClickPublishEquipment">PublishEquipment</Button>
      <Button @click="onClickBuyEquipment">BuyEquipment</Button>
      <Button @click="onClickConfirmFinish">ConfirmFinish</Button>
      <Button @click="onClickRollbackPurchase">RollbackPurchase</Button>
      <Button @click="onClickUnpublishEquipment">UnpublishEquipment</Button>
      <Button @click="onClickShowConfirmPage">ShowConfrim</Button>
      <button @click="onClickShowGamePage">ShowGame</button>
      <button @click="onClickShowPayPage">ShowPay</button>
    </div>

    <div class="head">
      <div class="wrap">
        <div class="left">
          <a href="#"><img src="images/s1.png" alt=""></a>
          <a href="#"><img src="images/s2.png" alt=""></a>
          <a href="#"><img src="images/s3.png" alt=""></a>
        </div>
        <div class="right">
          <a href="#" class="a1">Connect Wallet</a>
          <div class="btns">
            <a href="#">BUY</a>
            <a href="#">SELL</a>
          </div>
          <a href="#" class="a2">Starknet</a>
        </div>
      </div>
    </div>

    <div class="main">
      <div class="wrap">
        <div class="content">
          <div class="items">
            <div class="item">
              <div class="imgbox"><img src="images/img1.png" alt=""></div>
              <div class="link">
                <a href="#">
                  <span class="icon"><img src="images/im1.png" alt=""></span>
                  <span class="title">WOOD</span>
                </a>
                <a href="#">
                  <span class="icon"><img src="images/im1.png" alt=""></span>
                  <span class="title">STONE</span>
                </a>
                <a href="#">
                  <span class="icon"><img src="images/im1.png" alt=""></span>
                  <span class="title">GOLD</span>
                </a>
              </div>
            </div>
            <div class="item">
              <div class="imgbox"><img src="images/img2.png" alt=""></div>
              <div class="link">
                <a href="#" class="none">???</a>
              </div>
            </div>
            <div class="item">
              <div class="imgbox"><img src="images/img3.png" alt=""></div>
              <div class="link">
                <a href="#" class="none">???</a>
              </div>
            </div>
          </div>

          <PayPage v-show="visiblePayPage"/>
          <ConfirmModal v-show="visibleConfirmPage"/>
          <GamesPage v-show="visibleGamePage"/>
        </div>
      </div>
    </div>
  </div>

</template>

<script>
import {mapActions, mapMutations, mapState} from "vuex";
import PayPage from "@/components/PayPage";
import GamesPage from "@/components/GamesPage";
import ConfirmModal from "@/components/ConfirmModal";

export default {
  name: 'App',
  components: {PayPage, GamesPage, ConfirmModal},
  data() {
    return {}
  },
  mounted() {
  },
  computed: {
    ...mapState([
      'wallet_address', 'provider', 'account', 'contract',
      'visibleConfirmPage', 'visibleGamePage', 'visiblePayPage'
    ]),
  },
  methods: {
    ...mapActions([
      'connect_wallet',
      'query_equipment',
      'publish_equipment', 'buy_equipment', 'confirm_finish', 'rollback_purchase', 'unpublish_equipment'
    ]),
    ...mapMutations(['setVisibleConfirmPage', 'setVisibleGamePage', 'setVisiblePayPage']),
    async onClickQueryEquipment() {
      let e = await this.query_equipment(1)
      console.log(e)
    },
    async onClickPublishEquipment() {
      let tx = await this.publish_equipment({name: null, game: null, price: null, coin_address: null});
      console.log(tx);
    },
    async onClickBuyEquipment() {
      let tx = await this.buy_equipment(1);
      console.log(tx);
    },
    async onClickConfirmFinish() {
      let tx = await this.confirm_finish(1);
      console.log(tx)
    },
    async onClickRollbackPurchase() {
      let tx = await this.rollback_purchase(1);
      console.log(tx);
    },
    async onClickUnpublishEquipment() {
      let tx = await this.unpublish_equipment(1);
      console.log(tx);
    },
    onClickShowPayPage() {
      this.setVisiblePayPage(true)
    },
    onClickShowConfirmPage() {
      this.setVisibleConfirmPage(true)
    },
    onClickShowGamePage() {
      this.setVisibleGamePage(true)
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
