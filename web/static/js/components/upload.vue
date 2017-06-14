<template>
  <div class="upload">
    <div class="upload--loading" v-if="!loaded">
      {{ $t('Please wait...') }}
    </div>
    <div class="upload--submit" v-else-if="currentUser">
      upload ze file!
      {{ currentUser.id }}
      {{ currentUser.name }}
    </div>
    <div class="upload--submit" v-else-if="registerPanel">
      Register user!!

      <div v-if="error">
        <p class="sc-alert sc-alert--error" role="alert">{{ $t("Oops, something went wrong! Please check the errors below.") }}</p>
      </div>
      <form accept-charset="UTF-8" action="/users" class="user-form" v-on:submit.prevent="submitRegisterUser">
        <div>
          <label class="sc-label" for="user_name">Name</label>
          <input class="sc-input" id="user_name" placeholder="Name" type="text" v-model="registerName">
          <span class="sc-hint sc-hint--error" v-if="error.name">{{ error.name }}</span>
        </div>

        <div>
          <label class="sc-label" for="user_email">Email</label>
          <input class="sc-input" id="user_email" placeholder="Email" type="text" v-model="registerEmail">
          <span class="sc-hint sc-hint--error" v-if="error.email">{{ error.email }}</span>
        </div>

        <div>
          <label class="sc-label" for="user_password">Passwort</label>
          <input class="sc-input" id="user_password"  placeholder="Passwort" type="password" v-model="registerPassword">
          <span class="sc-hint sc-hint--error" v-if="error.password">{{ error.password }}</span>
        </div>

        <div>
          <label class="sc-label" for="user_password_confirmation">Passwort bestätigen</label>
          <input class="sc-input" id="user_password_confirmation" placeholder="Passwort bestätigen" type="password" v-model="registerPasswordConfirmation">
          <span class="sc-hint sc-hint--error" v-if="error.password_confirmation">{{ error.password_confirmation }}</span>
        </div>

        <div>
          <label class="sc-field sc-field--choice">
            <input name="user[want_newsletter]" type="hidden" value="false">
            <input id="user_want_newsletter" name="user[want_newsletter]" type="checkbox" value="true" v-model="registerWantNewsletter">
            Ja, ich will den Newsletter abonnieren.
          </label>
        </div>

        <div class="sc-actions">
          <button class="sc-button" type="submit" :disabled="submitted">Registrieren</button>
        </div>
      </form>
      <a v-on:click.stop="hideRegisterPanel">Login</a>
    </div>
    <div class="upload--login" v-else>
      login!
      <div v-if="error">
        <p class="sc-alert sc-alert--error" role="alert">{{ $t("The email or password was wrong.") }}</p>
      </div>
      <form accept-charset="UTF-8" class="login-form" v-on:submit.prevent="submitUserLogin">
        <div>
          <label class="sc-label" for="session_email">Email</label>
          <input class="sc-input" id="session_email" placeholder="Email" type="text" v-model="loginEmail">
        </div>

        <div>
          <label class="sc-label" for="session_password">Passwort</label>
          <input class="sc-input" id="session_password" placeholder="Passwort" type="password" v-model="loginPassword">
        </div>

        <p class="st-no-margin">
          <a href="/password/new" target="_blank">Passwort vergessen?</a> |
          <a v-on:click.stop="showRegisterPanel">Ein neues Nutzerkonto anlegen</a>
        </p>
        <div class="sc-actions">
          <button class="sc-button" type="submit" :disabled="submitted">Anmelden</button>
        </div>
      </form>
    </div>
    <router-link to="/cutter" class="upload--back">
      {{ $t('Back') }}
    </router-link>
  </div>
</template>

<script>

function refreshUser(self) {
  self.$http.get('/api/current_user').then(response => {
    self.currentUser = response.body.user
    self.loaded      = true
  }, response => {
    console.log("Sadly something went wrong:");
    console.log(response);
  });
}

export default {
  data() {
    return {
      currentUser: null,
      loaded: false,
      registerPanel: false,
      submitted: false,
      error: false
    }
  },
  mounted() {
    console.log("mounted!!");
    console.log(this.$store.state.startTime);
    console.log(this.$store.state.endTime);
    refreshUser(this);
  },
  methods: {
    showRegisterPanel: function(event) {
      this.registerPanel = true;
      this.error         = false;
    },
    hideRegisterPanel: function(event) {
      this.registerPanel = false
      this.error         = false;
    },
    submitUserLogin: function() {
      this.submitted = true;
      this.$http.post('/api/sessions', {
        email: this.loginEmail,
        password: this.loginPassword
      }).then(response => {
        this.submitted = false;
        this.error     = false;
        refreshUser(this);
      }, response => {
        this.submitted = false;
        this.error     = true
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
        this.submitted = false;
        this.error     = false;
        this.currentUser = response.body.user;
      }, response => {
        console.log("failure!");
        console.log(response.body.error);
        this.submitted = false;
        this.error     = response.body.error
      });
    }
  }
}
</script>

<style lang="sass">
</style>
