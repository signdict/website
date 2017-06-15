<template>
  <div class="upload">
    <div class="o-container o-container--medium">
      <header>
        <div class="o-grid o-grid--wrap">
          <div class="o-grid__cell o-grid__cell--width-100 o-grid__cell--width-50@medium">
            <a href="/"><img src='/images/logo.svg' :alt="$t('SignDict Logo')" class="so-navigation--logo"/></a>
            <a href='/about' class='so-navigation--about'>{{ $t('About SignDict') }}</a>
          </div>
        </div>
      </header>
    </div>
    <div class="sc-main o-container o-container--medium">
      <div class="o-grid__cell o-grid__cell--width-100">
        <h1>{{ $t('Nearly done...') }}</h1>
        <p>
          {{ $t('PleaseReview') }}
        </p>
        <div class="upload--video">
          <video class='upload--player' loop preload></video>
        </div>
        <router-link to="/cutter" class="upload--back">
          &lt;&lt; {{ $t('Back') }}
        </router-link>
        <div class="upload--loading" v-if="currentPanel == 'loading'">
          {{ $t('Please wait...') }}
        </div>
        <div class="upload--loading" v-if="currentPanel == 'uploading'">
          {{ $t('Uploading') }}
        </div>
        <div class="upload--submit" v-else-if="currentUser">
          <button class='sc-button' v-on:click.stop="uploadVideo">{{ $t('Upload video') }}</button>
        </div>
        <div class="upload--login-or-register" v-else>
          <h3>{{ $t('Login required') }}</h3>
          <p>
            {{ $t('PleaseLogin') }}
          </p>

          <div>
            <button class='sc-button' v-on:click.stop="showLoginPanel">{{ $t('I already have a SignDict account') }}</button>
          </div>

          <transition name="grow">
            <div class="upload--login" v-if="currentPanel == 'login'">
              <div v-if="loginError">
                <p class="sc-alert sc-alert--error" role="alert">{{ $t('The email or password was wrong.') }}</p>
              </div>
              <form accept-charset="UTF-8" class="login-form" v-on:submit.prevent="submitUserLogin">
                <div>
                  <label class="sc-label" for="session_email">{{ $t('Email') }}</label>
                  <input class="sc-input" id="session_email" :placeholder="$t('Email')" type="text" v-model="loginEmail">
                </div>

                <div>
                  <label class="sc-label" for="session_password">{{ $t('Password') }}</label>
                  <input class="sc-input" id="session_password" :placeholder="$t('Password')" type="password" v-model="loginPassword">
                </div>

                <p class="st-no-margin">
                  <a href="/password/new" target="_blank">{{ $t('Forgot password?') }}</a>
                </p>
                <div class="sc-actions">
                  <button class="sc-button" type="submit" :disabled="submitted">{{ $t('Login') }}</button>
                </div>
              </form>
            </div>
          </transition>

          <div>
            <button class='sc-button' v-on:click.stop="showRegisterPanel">{{ $t('I don\'t have a SignDict account') }}</button>
          </div>

          <transition name="grow">
            <div class="upload--register" v-if="currentPanel == 'register'">
              <div v-if="registerError">
                <p class="sc-alert sc-alert--error" role="alert">{{ $t('Oops, something went wrong! Please check the errors below.') }}</p>
              </div>
              <form accept-charset="UTF-8" action="/users" class="user-form" v-on:submit.prevent="submitRegisterUser">
                <div>
                  <label class="sc-label" for="user_name">{{ $t('Name') }}</label>
                  <input class="sc-input" id="user_name" :placeholder="$t('Name')" type="text" v-model="registerName">
                  <span class="sc-hint sc-hint--error" v-if="registerError.name">{{ registerError.name }}</span>
                </div>

                <div>
                  <label class="sc-label" for="user_email">{{ $t('Email') }}</label>
                  <input class="sc-input" id="user_email" :placeholder="$t('Email')" type="text" v-model="registerEmail">
                  <span class="sc-hint sc-hint--error" v-if="registerError.email">{{ registerError.email }}</span>
                </div>

                <div>
                  <label class="sc-label" for="user_password">{{ $t('Password') }}</label>
                  <input class="sc-input" id="user_password"  :placeholder="$t('Password')" type="password" v-model="registerPassword">
                  <span class="sc-hint sc-hint--error" v-if="registerError.password">{{ registerError.password }}</span>
                </div>

                <div>
                  <label class="sc-label" for="user_password_confirmation">{{ $t('Confirm password') }}</label>
                  <input class="sc-input" id="user_password_confirmation" :placeholder="$t('Confirm password')" type="password" v-model="registerPasswordConfirmation">
                  <span class="sc-hint sc-hint--error" v-if="registerError.password_confirmation">{{ registerError.password_confirmation }}</span>
                </div>

                <div>
                  <label class="sc-field sc-field--choice">
                    <input name="user[want_newsletter]" type="hidden" value="false">
                    <input id="user_want_newsletter" name="user[want_newsletter]" type="checkbox" value="true" v-model="registerWantNewsletter">
                    {{ $t('Yes, I want to subscribe to the newsletter') }}
                  </label>
                </div>

                <div class="sc-actions">
                  <button class="sc-button" type="submit" :disabled="submitted">{{ $t('Register') }}</button>
                </div>
              </form>
            </div>
          </transition>
        </div>
      </div>

    </div>
  </div>
</template>

<script>

let playingStart = 0;
let playingEnd   = 0;
let unmounted    = false;

function refreshUser(self) {
  self.$http.get('/api/current_user').then(response => {
    self.currentUser = response.body.user
    self.currentPanel = 'info'
  }, response => {
    console.log("Sadly something went wrong:");
    console.log(response);
  });
}

function getVideoElement() {
  return document.getElementsByClassName("upload--player")[0];
}

function initVideoPlayer(self, blobs) {
  let videoElement = getVideoElement();
  videoElement.src = window.URL.createObjectURL(new Blob(blobs));
  playingStart     = self.$store.state.startTime;
  playingEnd       = self.$store.state.endTime;
  unmounted        = false;
  window.requestAnimationFrame(updateVideoPosition);
  videoElement.play();
}

function destroyVideoPlayer() {
  unmounted = false;
}

function updateVideoPosition() {
  let player = getVideoElement();
  if (player) {
    let currentTime = player.currentTime;
    if (currentTime + 0.2 < playingStart) {
      currentTime = playingStart;
      getVideoElement().currentTime = playingStart;
    } else if (currentTime > playingEnd) {
      currentTime = playingEnd;
      getVideoElement().currentTime = playingStart;
    }
  }
  if (!unmounted) {
    window.requestAnimationFrame(updateVideoPosition);
  }
}

function scrollToBottom() {
  setTimeout(function() {
    window.scrollTo(0,document.body.scrollHeight);
  }, 100)
}

export default {
  data() {
    return {
      currentUser:   null,
      currentPanel:  'loading',
      submitted:     false
    }
  },
  mounted() {
    let blobs = this.$store.state.recordedBlobs;
    initVideoPlayer(this, blobs);
    refreshUser(this);
  },
  beforeDestroy() {
    destroyVideoPlayer();
  },
  methods: {
    showRegisterPanel: function(event) {
      this.currentPanel   = 'register'
      this.registerError  = false;
      scrollToBottom();
    },
    showLoginPanel: function(event) {
      this.currentPanel   = 'login'
      this.loginError     = false;
      scrollToBottom();
    },
    submitUserLogin: function() {
      this.submitted = true;
      this.$http.post('/api/sessions', {
        email: this.loginEmail,
        password: this.loginPassword
      }).then(response => {
        this.submitted  = false;
        this.loginError = false;
        refreshUser(this);
      }, response => {
        this.submitted  = false;
        this.loginError = true
      });
    },
    submitRegisterUser: function() {
      this.submitted = true;
      this.$http.post('/api/register', {
        user: {
          name: this.registerName,
          email: this.registerEmail,
          password: this.registerPassword,
          password_confirmation: this.registerPasswordConfirmation
        }
      }).then(response => {
        this.submitted     = false;
        this.registerError = false;
        this.currentUser   = response.body.user;
      }, response => {
        this.submitted     = false;
        this.registerError = response.body.error
      });
    },
    uploadVideo: function() {
      this.currentPanel = 'uploading';
      console.log("Upload video...");
    }
  }
}
</script>

<style lang="sass">
.upload {
  padding: 1em;
}

.upload--player {
  width: 100%;
}

.upload--login {
  margin: 2em 0;
}

.upload--register {
  margin: 2em 0;
}

.upload--submit {
  text-align: center;
}

.grow-enter-active,
.grow-leave-active {
  transition: all 0.2s;
}
.grow-enter-to,
.grow-leave {
  opacity: 100%;
  height: auto;
}

.grow-enter,
.grow-leave-to
{
  margin: 0;
  opacity: 0;
  height: 0px;
  overflow: hidden;
}
</style>
