<template>
  <div class="dashboard-page">
    <Widget title="<h1 class='page-title'>Pages</h1>" customHeader>
      <b-button v-b-modal.modal-prevent-closing>Add Pages</b-button>

      <b-modal
        id="modal-prevent-closing"
        ref="modal"
        title="Submit Your Name"
        @show="resetModal"
        @hidden="resetModal"
        @ok="handleOk"
      >
        <form ref="form" @submit.stop.prevent="handleSubmit">
          <b-form-group
            :state="nameState"
            label="Name"
            label-for="name-input"
            invalid-feedback="Name is required"
          >
            <b-form-input
              id="name-input"
              v-model="name"
              :state="nameState"
              required
            ></b-form-input>
          </b-form-group>
        </form>
      </b-modal>
      <hr />
      <span v-if="NoPages">No Pages Please add page</span>

      <div v-else class="mid-sec recent-doc-sec mt-3">
        <div
          class="accordion"
          role="tablist"
          v-for="page in submittedNames"
          :key="page.id"
        >
          <b-card no-body class="mb-1">
            <b-card-header header-tag="header" role="tab">
              <b-button block :v-b-toggle="page.id" variant="info">
                {{ page.url }}</b-button
              >
            </b-card-header>
            <b-collapse
              :id="page.id"
             visible accordion="my-accordion" role="tabpanel"
            >
              <b-card-body>
                <b-embed type="iframe"  :src="page.url"></b-embed>
              </b-card-body>
            </b-collapse>
          </b-card>
        </div>
      </div>
    </Widget>
  </div>
</template>

<script>
import Widget from "@/components/Widget/Widget";

export default {
  name: "Dashboard",
  components: {
    Widget,
  },
  data() {
    return {
      loading: false,
      errored: false,

      newUrl: "",
      newUrlState: null,
      PageList: [],

      name: "",
      nameState: null,
      submittedNames: [
        {id:'page-1',url:'https://bootstrap-vue.org/docs/components/collapse'}
      ],
    };
  },
  computed: {
    NoPages() {
      return this.submittedNames == null || this.submittedNames.length == 0;
    },
  },

  methods: {
    checkFormValidity() {
      const valid = this.$refs.form.checkValidity();
      this.nameState = valid;
      return valid;
    },
    resetModal() {
      this.name = "";
      this.nameState = null;
    },
    handleOk(bvModalEvt) {
      // Prevent modal from closing
      bvModalEvt.preventDefault();
      // Trigger submit handler
      this.handleSubmit();
    },
    handleSubmit() {
      // Exit when the form isn't valid
      if (!this.checkFormValidity()) {
        return;
      }
      // Push the name to submitted names
      var index = 'page-'+ ( this.submittedNames.length + 1).toString();

      this.submittedNames.push({ id: index, url: this.name });
      // Hide the modal manually
      this.$nextTick(() => {
        this.$bvModal.hide("modal-prevent-closing");
      });
    },
  },
  mounted() {},
};
</script>

<style src="./Dashboard.scss" lang="scss" />
