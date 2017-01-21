<template>
  <div class="hello">
    <canvas id="megaCanvas" width="800" height="400"></canvas>
    <div>
      <a class="btn" href="#" v-bind:class="{win: win}" v-on:click.prevent="backToMenu()">Back to menu</a>
    </div>
    <div>
      <h4>Waves</h4>
      <p class="help-text" v-if="!sines.length">Start by adding a wave</p>

      <p class="help-text" v-if="sines.length > 0 && selectedWave !== null">Use <span class="key">↑</span><span class="key">↓</span> to control amplitude, <span class="key">←</span><span class="key">→</span> to move the wave and <span class="key">a</span><span class="key">s</span> to control wave count.</p>

      <p class="help-text" v-if="sines.length > 0 && selectedWave === null">Select wave using <span class="key">1</span><span class="key">2</span><span class="key">3</span><span class="key">4</span><span class="key">5</span>.</p>
      <div v-on:click.prevent="selectWave(index)" class="wave" v-bind:class="{ active: selectedWave == index}" v-for="(sin, index) in sines">
        <wave v-bind:A="sin.A" v-bind:w="sin.w" v-bind:o="sin.o"></wave>
        <!-- {{ sin.A }} * sin({{sin.w}}*w + {{ sin.o }})<br> -->
<!-- 
        <strong>Strength:</strong>
        <a style="padding-right: 2px;" href="#" v-on:click.prevent="changeWaveA(sin, A)" v-for="A in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]">{{ A }}</a href="#">

        <strong>w:</strong>
        <a style="padding-right: 2px;" href="#" v-on:click.prevent="changeWaveW(sin, W)" v-for="W in [0.005, 0.01, 0.02, 0.03]">{{ W }}</a href="#">

 -->
        <a href="#" class="remove" v-on:click.prevent="removeWave(sin)"><i class="fa fa-trash" aria-hidden="true"></i></a>
      </div>
      <a class="add-wave" href="#" v-on:click.prevent="addWave()"><i class="fa fa-plus" aria-hidden="true"></i></a>
    </div>
  </div>
</template>

<script>
import _ from 'lodash';
import events from '../events';
import pickRandom from 'pick-random';
import mousetrap from 'mousetrap';
import Wave from './Wave';

const POINT_DISTANCE = 20;

function generatePoints(pointCount=6, sinCount=7, dangerCount=2) {
  var sines = [];
  for (var k=0; k <= sinCount; k++) {
    sines.push({
        A: pickRandom([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]),
        w: pickRandom([0.005, 0.01, 0.02, 0.03]),
        o: _.random(0, 100),
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
      match: false,
      danger: false
    })
  }

  var output = [];

  for (var x=50; x < 50+Math.round(700/pointCount)*pointCount; x += Math.round(700/pointCount)) {
    output.push(potentialPoints[x]);
  }

  var dangerPoints = [];
  while (dangerPoints.length < dangerCount) {
    let x = _.random(50, 750);
    let y = _.random(50, 350);

    var value = 0;
    for (let sin of sines) {
      value += sin.A * Math.sin(sin.w * (x) + sin.o);
    }
    var pointY = 180.0 - value * 120;
    if (Math.abs(pointY - y) <= 40) {
      continue;
    }

    dangerPoints.push({
      x,
      y,
      lastMatch: 0,
      match: false,
      danger: true
    });
  }

  output = output.concat(dangerPoints);

  return [output, sines];
}


function updateDisplay() {
  if (!this.alive) {
    return;
  }

  const time = Date.now() - this.time;
  this.ctx.fillStyle = 'white';
  this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
  // this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

  this.ctx.strokeStyle = '#2c3e50';
  this.ctx.lineWidth = 2;
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
      if (d <= POINT_DISTANCE) {
        point.match = true;
        point.lastMatch = Date.now();
      }
    }
  }

  // Draw winning
  if (this.win) {
    this.ctx.strokeStyle = '#d35400';
    this.ctx.beginPath();
    this.ctx.moveTo(0,180);

    for(var x=0; x <= this.canvas.width; x += 1) {
      var value = 0;
      for (let sin of this.winSines) {
        value += sin.A * Math.sin(sin.w * x + sin.o);
      }

      var y = 180.0 - value * 120;
      this.ctx.lineTo(x,y);
    }
    this.ctx.stroke();
  }

  // Draw without active one
  // this.ctx.strokeStyle = '#bdc3c7';
  // this.ctx.beginPath();
  // this.ctx.moveTo(0,180);

  // for(var x=0; x <= this.canvas.width; x += 1) {
  //   var value = 0;
  //   var i = 0;
  //   for (let sin of this.sines) {
  //     if (i !== this.selectedWave) {
  //       value += sin.A * Math.sin(sin.w * x + sin.o);
  //     }
  //     i += 1;
  //   }

  //   var y = 180.0 - value * 120;
  //   this.ctx.lineTo(x,y);
  // }
  // this.ctx.stroke();

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
        if (point.match && !point.danger) {
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
  var goodPoints = this.points.filter(x => !x.danger).length;
  if (!this.points.filter(x => !x.match && !x.danger).length && !this.points.filter(x => x.match && x.danger).length) {
    this.win = true;
  }
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
    if (point.danger) {
      this.ctx.strokeStyle = '#c0392b';
    } else {
      this.ctx.strokeStyle = '#27ae60';
    }

    var diff = Date.now() - point.lastMatch;
    //var r = Math.min(16, 8 + (diff/400));
    // var r = 10;

    this.ctx.beginPath();

    if (point.match) {

      if (point.danger) {
        this.ctx.arc(point.x, point.y, POINT_DISTANCE, 0, 2 * Math.PI, true);
      } else {
        this.ctx.arc(point.x, point.y + 3*Math.sin((time + x*342.12345)*0.02 + x*163.12345), POINT_DISTANCE, 0, 2 * Math.PI, true);
      }


      this.ctx.stroke();  
      if (point.danger) {
        this.ctx.fillStyle = '#c0392b';
      } else {
        this.ctx.fillStyle = '#27ae60';
      }
      this.ctx.fill();
    } else {
      this.ctx.arc(point.x, point.y, POINT_DISTANCE, 0, 2 * Math.PI, true);
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
  name: 'play',
  props: ['level'],
  components: {
    Wave
  },
  methods: {
    backToMenu() {
      events.$emit('menu');
    },
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
      points: [],
      sines: [/*{
        A: 1,
        w: 0.02,
        o: 0
      }*/],
      selectedWave: 0,
      win: false
    }
  },
  watch: {
    selectedWave() {
      if (this.selectedWave >= this.sines.length) {
        this.selectedWave = null;
      }
    },
    win() {
      if (this.win) {
        var winLevels = JSON.parse(window.localStorage['winLevels'] || '{}');
        winLevels[this.level] = true;
        window.localStorage['winLevels'] = JSON.stringify(winLevels);
      }
    }
  },
  mounted() {
    console.log('MOUNT');
    [ this.points, this.winSines ] = generatePoints(this.level, Math.round((this.level + 2)*0.33), 2 + Math.round(this.level * 0.5));
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
a.add-wave {
  font-size: 40px;
  border: 1px #42b983 solid;
  display: inline-block;
  width: 60px;
  height: 60px;
  line-height: 70px;
  border-radius: 100%;
  text-align: center;
  margin-left: 30px;
  margin-right: 30px;
}
a.add-wave:hover {
  background-color: #42b983;
  color: white;
}

.wave {
  display: inline-block;
  border: 1px #2c3e50 solid;
  padding: 5px;
  border-radius: 10px;
  margin: 10px;
  position: relative;
  cursor: pointer;
  user-select: none;
}
.wave .remove {
  text-decoration: none;
  color: #34495e;
  border-radius:  100%;
  border: 1px #34495e solid;
  width:  25px;
  height: 25px;
  text-align: center;
  line-height: 25px;
  display: inline-block;
  position: absolute;
  bottom: 5px;
  right: 5px;
}
.wave .remove:hover {
  border: 1px #c0392b solid;
  background-color: #c0392b;
  color: white;
}
.wave.active {
  border: 1px #2980b9 solid;
  background:  #ecf0f1;
}
.btn {
  display: inline-block;
  background-color: #34495e;
  text-decoration: none;
  color: white;
  padding: 10px;
  border-radius: 10px;
}
.btn.win {
  background-color: #27ae60;
}
.help-text {
  font-weight: bold;
}
.key {
  display: inline-block;
  border: 1px gray solid;
  padding: 4px;
  margin: 2px;
  border-radius: 2px 2px;
}
</style>
