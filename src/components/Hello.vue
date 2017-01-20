<template>
  <div class="hello">
    <canvas id="megaCanvas" width="800" height="400"></canvas>
    <div>
      Score: {{ score }}
    </div>
    <div>
      <h4>Waves</h4>
      <div v-on:click.prevent="selectWave(index)" class="wave" v-bind:class="{ active: selectedWave == index}" v-for="(sin, index) in sines">
        <wave v-bind:A="sin.A" v-bind:w="sin.w" v-bind:o="sin.o"></wave>
        <!-- {{ sin.A }} * sin({{sin.w}}*w + {{ sin.o }})<br> -->
<!-- 
        <strong>Strength:</strong>
        <a style="padding-right: 2px;" href="#" v-on:click.prevent="changeWaveA(sin, A)" v-for="A in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]">{{ A }}</a href="#">

        <strong>w:</strong>
        <a style="padding-right: 2px;" href="#" v-on:click.prevent="changeWaveW(sin, W)" v-for="W in [0.005, 0.01, 0.02, 0.03]">{{ W }}</a href="#">

 -->
        <a href="#" class="remove" v-on:click.prevent="removeWave(sin)">Remove</a>
      </div>
      <a href="#" v-on:click.prevent="addWave()">Add wave</a>
    </div>
  </div>
</template>

<script>
import _ from 'lodash';
import pickRandom from 'pick-random';
import mousetrap from 'mousetrap';
import Wave from './Wave';

function generatePoints(pointCount=6, sinCount=7) {
  var sines = [];
  for (var k=0; k <= sinCount; k++) {
    sines.push({
        A: pickRandom([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]),
        w: pickRandom([0.005, 0.01, 0.02, 0.03]),
        o: _.random(0, 100)
    });
  }
  var potentialPoints = [];

  for(var x=0; x <= 800; x += 1) {
    var value = 0;
    for (let sin of sines) {
      value += sin.A * Math.sin(sin.w * (x) + sin.o);
    }
    var y = 180.0 - value * 120;
    potentialPoints.push({
      x: Math.round(x),
      y: Math.round(y),
      lastMatch: 0,
      match: false
    })
  }

  var output = [];

  for (var x=50; x <= 50+Math.round(700/pointCount)*pointCount; x += Math.round(700/pointCount)) {
    output.push(potentialPoints[x]);
  }
  return output;
}

console.log(generatePoints());

function updateDisplay() {
  if (!this.alive) {
    return;
  }

  const time = Date.now() - this.time;
  this.ctx.fillStyle = 'white';
  this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
  // this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

  this.ctx.strokeStyle = '#2c3e50';
  this.ctx.beginPath();
  this.ctx.moveTo(0,180);

  for (let point of this.points) {
    point.match = false;
  }

  // Calculate matches first
  for(var x=0; x <= this.canvas.width; x += 1) {
    var value = 0;
    for (let sin of this.sines) {
      value += sin.A * Math.sin(sin.w * x + sin.o);
    }
    var y = 180.0 - value * 120;

    for (let point of this.points) {
      var d = Math.sqrt(Math.pow(x - point.x, 2) + Math.pow(y - point.y, 2));
      if (d <= 10) {
        point.match = true;
        point.lastMatch = Date.now();
      }
    }
  }

  // Draw without active one

  this.ctx.strokeStyle = '#bdc3c7';
  this.ctx.beginPath();
  this.ctx.moveTo(0,180);

  for(var x=0; x <= this.canvas.width; x += 1) {
    var value = 0;
    var i = 0;
    for (let sin of this.sines) {
      if (i !== this.selectedWave) {
        value += sin.A * Math.sin(sin.w * x + sin.o);
      }
      i += 1;
    }

    var y = 180.0 - value * 120;
    this.ctx.lineTo(x,y);
  }
  this.ctx.stroke();

  // Draw
  this.ctx.strokeStyle = '#2c3e50';
  this.ctx.beginPath();
  this.ctx.moveTo(0,180);
  
  for(var x=0; x <= this.canvas.width; x += 1) {
    var value = 0;
    for (let sin of this.sines) {
      value += sin.A * Math.sin(sin.w * x + sin.o);
    }

    var closestDistance = (() => {
      var closestDistance = 10000;
      for (let point of this.points) {
        if (point.match) {
          closestDistance = Math.min(closestDistance, Math.abs(x - point.x));
        }
      }
      return closestDistance;
    })();
    if (closestDistance <= 100) {
      value += 0.05 * Math.sin(x*0.5) * (1 - closestDistance/100) * Math.sin(time*0.03);
    }

    var y = 180.0 - value * 120;
    this.ctx.lineTo(x,y);
  }
  this.ctx.stroke();

  // Draw particles
  this.particles = this.particles.filter(x => x.time <= 100);
  this.score = Math.max(this.score, this.points.filter(x => x.match).length);
  // for (let particle of this.particles) {
  //   particle.y -= particle.speedY;
  //   particle.speedY += 0.1;
  //   particle.time += 2;
  //   const opacity = 1 * (particle.time/100);
  //   this.ctx.strokeStyle = `rgba(0.4, 0.4, 0.4, ${opacity})`;

  //   //var r = Math.min(16, 8 + (diff/400));

  //   this.ctx.beginPath();
  //   this.ctx.arc(particle.x, particle.y, 4, 0, 2 * Math.PI, true);
  //   this.ctx.stroke();  
  // }
  // Draw point lines
  // this.ctx.beginPath();
  // this.ctx.strokeStyle = '#f39c12';
  // let i = 0;
  // for (let point of this.points) {
  //   if (point.match) {
  //     if (i === 0) {
  //       this.ctx.moveTo(point.x, point.y);
  //     } else {
  //       this.ctx.lineTo(point.x, point.y);
  //     }
  //     i++;
  //   }
  // }
  // this.ctx.stroke();

  // Draw points
  for (let point of this.points) {
    this.ctx.strokeStyle = '#f39c12';

    var diff = Date.now() - point.lastMatch;
    //var r = Math.min(16, 8 + (diff/400));
    var r = 10;

    this.ctx.beginPath();

    if (point.match) {
      this.ctx.arc(point.x, point.y + 3*Math.sin((time + x*342.12345)*0.02 + x*163.12345), r, 0, 2 * Math.PI, true);
      this.ctx.stroke();  
      this.ctx.fillStyle = '#f39c12';
      this.ctx.fill();
    } else {
      this.ctx.arc(point.x, point.y, r, 0, 2 * Math.PI, true);
      this.ctx.stroke();  
    }
  }

  requestAnimationFrame(updateDisplay.bind(this));
}

function generatePoint() {
  return {
    x: Math.random() * 700 + 50,
    y: Math.random() * 350 + 25,
    lastMatch: 0,
    match: false
  };
}

// A*sin(wx + o)
export default {
  name: 'hello',
  components: {
    Wave
  },
  methods: {
    selectWave(index) {
      if (this.selectedWave === index) {
        this.selectedWave = null;
      } else {
        this.selectedWave = index;
      }
    },
    addWave() {
      this.sines.push({
        A: 0.3,
        w: 0.01,
        o: 0
      });
      this.selectedWave = this.sines.length-1;
    },
    removeWave(wave) {
      this.sines = _.without(this.sines, wave);
    },
    changeWaveA(wave, A) {
      wave.A = A;
    },
    changeWaveW(wave, W) {
      wave.w = W;
    },
    bindKeys() {
      mousetrap.reset();

      for (let k=1; k<=9; k++) {
        mousetrap.bind(String(k), e => {
          this.selectedWave = k-1;
        });
      }
      mousetrap.bind('left', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.o += 0.1;
        }
      });
      mousetrap.bind('right', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.o -= 0.1;
        }
      });
      mousetrap.bind('up', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.A += 0.05;
        }
      });
      mousetrap.bind('down', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.A -= 0.05;
        }
      });
      mousetrap.bind('a', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.w -= 0.00025;
        }
      });
      mousetrap.bind('s', e => {
        var wave = this.sines[this.selectedWave];
        if (wave) {
          wave.w += 0.00025;
        }
      });
    }
  },
  data () {
    return {
      alive: true,
      score: 0,
      particles: [],
      points: generatePoints(5, 3),
      sines: [{
        A: 1,
        w: 0.02,
        o: 0
      }],
      selectedWave: 0,
      msg: 'Welcome to Your Vue.js App'
    }
  },
  mounted() {
    console.log('MOUNT');
    this.time = Date.now();
    this.canvas = document.getElementById('megaCanvas');
    this.ctx = this.canvas.getContext('2d');
    
    updateDisplay.bind(this)();
    this.bindKeys();
  },
  destroyed() {
    this.alive = false;
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
  border: 1px #2c3e50 solid;
  padding: 5px;
  border-radius: 10px;
  margin: 10px;
}
.wave .remove {
  text-decoration: none;
  color: #34495e;
}
.wave.active {
  border: 1px #2980b9 solid;
  background:  #ecf0f1;
}
</style>
