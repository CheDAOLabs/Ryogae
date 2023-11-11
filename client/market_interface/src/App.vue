<template>
  <div>
        <div class="test">
    <!--      <Button @click="connect_wallet">{{ wallet_address ? wallet_address : "Connect Wallet" }}</Button>-->
    <!--      <Button @click="onClickQueryEquipment">QueryEquipment</Button>-->
    <!--      <Button @click="onClickPublishEquipment">PublishEquipment</Button>-->
    <!--      <Button @click="onClickBuyEquipment">BuyEquipment</Button>-->
    <!--      <Button @click="onClickConfirmFinish">ConfirmFinish</Button>-->
    <!--      <Button @click="onClickRollbackPurchase">RollbackPurchase</Button>-->
    <!--      <Button @click="onClickUnpublishEquipment">UnpublishEquipment</Button>-->
    <!--      <Button @click="onClickShowConfirmPage">ShowConfrim</Button>-->
    <!--      <button @click="onClickShowGamePage">ShowGame</button>-->
    <!--      <button @click="onClickShowPayPage">ShowPay</button>-->
          <Button @click="onEncodeString">EncodeString</Button>
        </div>

    <div class="head">
      <div class="wrap">
        <div class="left">
          <a href="#"><img src="images/s1.png" alt=""></a>
          <a href="#"><img src="images/s2.png" alt=""></a>
          <a href="#"><img src="images/s3.png" alt="" @click="onClickOrder"></a>
        </div>
        <div class="right">
          <a href="#" class="a1" @click="connect_wallet">{{
              wallet_address ? wallet_address.substring(0, 5) + "..." + wallet_address.substring(wallet_address.length - 5, wallet_address.length) : "Connect Wallet"
            }}</a>
          <div class="btns">
            <a href="#" @click="onClickBuy" :class="[{ 'page_off': this.page!=='BUY' }]">BUY</a>
            <a href="#" @click="onClickSell" :class="[{ 'page_off': this.page!=='SELL' }]">SELL</a>
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
                <a href="#" @click="onClickWood">
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

          <PayPage v-if="visiblePayPage"/>
          <ConfirmModal v-if="visibleConfirmPage"/>
          <GamesPage v-if="visibleGamePage"/>
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
import {shortString} from "starknet";

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
      'wallet_address', 'provider', 'account', 'page',
      'visibleConfirmPage', 'visibleGamePage', 'visiblePayPage'
    ]),
  },
  methods: {
    ...mapActions([
      'connect_wallet',
      'query_equipment',
      'publish_equipment', 'buy_equipment', 'confirm_finish', 'rollback_purchase', 'unpublish_equipment'
    ]),
    ...mapMutations([
      'setVisibleConfirmPage', 'setVisibleGamePage', 'setVisiblePayPage', 'setPage'
    ]),
    async onClickQueryEquipment() {
      let e = await this.query_equipment(1)
      console.log(e)
    },
    async onClickPublishEquipment() {
      let tx = await this.publish_equipment(
          {
            name: '0x111',
            game: '0x02a284ee5cc310ae2511ddd8f1a10b333cfd94279525737adb72c897f5d5d67b',
            price: '0x01',
            coin_address: '0x022dfc81fef882f1588aa8ab4dc3151c5a16debc8e9fc9284be3ae301da15c35'
          });

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
    },
    onClickSell() {
      this.setPage("SELL")
    },
    onClickBuy() {
      this.setPage("BUY")
    },
    async onClickWood() {
      if (this.wallet_address === "") {
        await this.connect_wallet()
      }
      if (this.page === 'BUY') {
        this.setVisiblePayPage(true)
      }
      if (this.page === 'SELL') {
        this.setVisibleGamePage(true)
      }
    },
    async onClickOrder() {
      if (this.wallet_address === "") {
        await this.connect_wallet()
      }
      this.setVisibleConfirmPage(true)
    },
    async onEncodeString() {
      const name = 'abc';
      const hex = shortString.encodeShortString(name);
      console.log("hex:", hex)
    }
  }
}
</script>

<style>

/*.page_on {*/
/*  background: #fbe1bb; !important;*/
/*  color: #000;!important;*/
/*}*/

.page_off {
  background: #747474 !important;
  color: #fbe1bb !important;
}
</style>
