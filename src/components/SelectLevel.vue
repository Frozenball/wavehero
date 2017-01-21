<template>
  <div class="select-level">
    <a href="#" v-for="i in levels" v-on:click.prevent="selectLevel(i)" v-bind:class="{ win: winLevels[i], locked: i > playable}">{{ i }}</a>
  </div>
</template>

<script>
import events from '../events';

export default {
  name: 'select-level',
  computed: {
    playable() {
      return Object.keys(this.winLevels).length + 2;
    }
  },
  data() {
    return {
      levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      winLevels: {}
    };
  },
  mounted() {
    this.winLevels = JSON.parse(window.localStorage['winLevels'] || '{}');
  },
  methods: {
    selectLevel(i) {
      if (i > this.playable) {
        return;
      }
      // console.log('selectLevel', i);
      events.$emit('selectLevel', i);
    }
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.select-level {
  width: 760px;
  min-height: 400px;
  margin: 0px auto;
  border: 1px #95a5a6 solid;
  padding: 20px;
}
.select-level a {
  display:  inline-block;
  padding: 10px;
  margin: 5px;
  background-color: #95a5a6;
  width: 100px;
  height: 100px;
  line-height: 100px;
  font-size: 30px;
  border-radius: 10px;
  text-decoration: none;
  color: white;
}
.select-level a.locked {
  color: white;
  opacity: 0.3;
  cursor: default;
}
.select-level a.win {
  background-color: #27ae60;
  color: white;
}
</style>
