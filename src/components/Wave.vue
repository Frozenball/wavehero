<template>
  <div>
    <canvas class="waveCanvas" width="200" height="100"></canvas>
  </div>
</template>

<script>
export default {
  name: 'hello',
  props: ['A', 'w', 'o'],
  methods: {
    draw() {
      this.canvas = this.$el.querySelector('.waveCanvas');
      this.ctx = this.canvas.getContext('2d');

      const scale = 200/800;

      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.ctx.strokeStyle = '#2c3e50';
      this.ctx.moveTo(0,180);
      this.ctx.beginPath();
      
      for(var x=0; x <= this.canvas.width; x += 1) {
        var value = 0;
        value += this.A * Math.sin(this.w * x/scale + this.o);

        var y = 180.0*scale - value * 120*scale;
        this.ctx.lineTo(x,y);
      }
      this.ctx.stroke();
    }
  },
  data () {
    return {};
  },
  watch: {
    A() { this.draw(); },
    w() { this.draw(); },
    o() { this.draw(); },
  },
  mounted() {
    this.draw();
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.hello {
  width: 800px;
  margin: 0px auto;
}
h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}

.wave {
  display: inline-block;
  border: 1px #7f8c8d solid;
  padding: 5px;
  border-radius: 10px;
}
.wave.active {
  background-color:  yellow;
}
</style>
