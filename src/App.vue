<template>
  <div id="app">
    <h1>Wave Hero</h1>
    <!-- <hello></hello> -->
    <select-level v-if="state === 'select-level'"></select-level>
    <play v-if="state === 'play'" v-bind:level="level"></play>
  </div>
</template>

<script>
import events from './events';

import Play from './components/Play'
import SelectLevel from './components/SelectLevel'

export default {
  name: 'app',
  components: {
    Play,
    SelectLevel
  },
  data() {
    return {
      state: 'select-level',
      level: 0
    };
  },
  created() {
    events.$on('selectLevel', (level) => {
      this.state = 'play';
      this.level = level;
    });
    events.$on('menu', (level) => {
      this.state = 'select-level';
    });
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
