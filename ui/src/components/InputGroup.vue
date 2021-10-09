<template>
  <b-input-group :id="groupID" class="mt-1 mb-2">
    <b-input-group-prepend is-text>
      <b-icon :icon="icon" :variant="variant"></b-icon>
    </b-input-group-prepend>
    <b-form-input
      :id="inputID"
      :name="inputID"
      :type="type"
      v-model="$v.value.$model"
      :state="validateState()"
      :aria-describedby="errorDescribedBy"
      :placeholder="placeholder"
    ></b-form-input>

    <b-form-invalid-feedback
      :id="errorDescribedBy"
      v-if="!$v.value.required  && $v.value.required !== undefined"
    >{{placeholder}} required</b-form-invalid-feedback>

    <b-form-invalid-feedback
      :id="errorDescribedBy"
      v-if="!$v.value.email  && $v.value.email !== undefined"
    >Email is invalid</b-form-invalid-feedback>

    <b-form-invalid-feedback
      :id="errorDescribedBy"
      v-if="!$v.value.minLength && $v.value.minLength !== undefined"
    >The minimum length of this field is {{this.minLength}} characters</b-form-invalid-feedback>

    <b-form-invalid-feedback
      :id="errorDescribedBy"
      v-if="!$v.value.maxLength && $v.value.maxLength !== undefined"
    >You have exceeded the length of this field</b-form-invalid-feedback>
  </b-input-group>
</template>

<script>
import { validationMixin } from 'vuelidate'
import {
  required,
  email,
  maxLength,
  minLength
} from 'vuelidate/lib/validators'

export default {
  mixins: [validationMixin],
  props: {
    inputValue: {
      type: [String, Number],
      default: null
    },
    validators: {
      type: Array,
      required
    },
    maxLength: {
      type: Number,
      default: 255
    },
    minLength: {
      type: Number,
      default: 0
    },
    groupID: {
      type: String,
      required
    },
    inputID: {
      type: String,
      required
    },
    icon: {
      type: String,
      required
    },
    variant: {
      type: String,
      default: 'primary'
    },
    type: {
      type: String,
      required
    },
    errorDescribedBy: {
      type: String,
      required
    },
    placeholder: {
      type: String,
      required
    }
  },

  data () {
    return {
      value: null,
      checks: {}
    }
  },

  created () {
    this.value = this.inputValue

    if (this.validators.includes('required')) {
      this.checks = { ...this.checks, required }
    }
    if (this.validators.includes('email')) {
      this.checks = { ...this.checks, email }
    }
    if (this.validators.includes('maxLength')) {
      this.checks = { ...this.checks, maxLength: maxLength(this.maxLength) }
    }
    if (this.validators.includes('minLength')) {
      this.checks = { ...this.checks, minLength: minLength(this.minLength) }
    }
  },

  methods: {
    validateState () {
      this.$emit('result', this.value)

      const { $dirty, $error } = this.$v.value
      return $dirty ? !$error : null
    },

    checkForm () {
      this.$v.value.$touch()
      if (this.$v.value.$anyError) {
        return false
      }
      return true
    },

    resetForm () {
      this.value = null
      this.$nextTick(() => {
        this.$v.$reset()
      })
    }
  },

  validations () {
    return {
      value: {
        ...this.checks
      }
    }
  }
}
</script>
