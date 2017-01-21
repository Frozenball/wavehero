<template>
  <div class="popup" v-if="visible">
    <a href="#" class="close" v-on:click.prevent="hide()"><i class="fa fa-times" aria-hidden="true"></i></a>
    <p>{{ text }}</p>
  </div>
</template>

<script>
export default {
  name: 'popup',
  props: ['text'],
  methods: {
    hide() {
      this.visible = false;
    }
  },
  data() {
    return {
      visible: true,
    };
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.popup {
  background-color: #2980b9;
  color: white;
  border-radius: 10px;
  padding: 20px;
  width: 500px;
  position: absolute;
  left: 150px;
  text-align: left;
  top: 100px;
  padding-top: 0;
  padding-bottom: 0;
  padding-right: 40px;
}
.popup .close {
  position: absolute;
  top: 10px;
  right: 15px;
  color: white;
  font-size: 20px;
}
</style>
