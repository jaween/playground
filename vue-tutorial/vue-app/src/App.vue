<template>
  <div id="app" class="small-container">
    <router-view/>
    <router-link to="/">Home</router-link>
    </br></br>
    <router-link to="/another">Another</router-link>
    <h1>Employee</h1>

    <employee-form @add:employee="addEmployee"/>
    <employee-table
      :employees="employees"
      @delete:employee="deleteEmployee"
      @edit:employee="editEmployee"
    />
  </div>
</template>

<script>
import EmployeeTable from '@/components/EmployeeTable.vue'
import EmployeeForm from '@/components/EmployeeForm.vue'

export default {
  name: 'app',
  components: {
    EmployeeTable,
    EmployeeForm,
  },
  data() {
    return {
      employees: [],
    }
  },

  mounted() {
    this.getEmployees();
  },

  methods: {
    async getEmployees() {
      try {
        const response = await fetch('https://jsonplaceholder.typicode.com/users');
        const data = await response.json();
        this.employees = data;
      } catch (error) {
        //console.error(error);
      }
    },

    async addEmployee(employee) {
      try {
        const response = await fetch('https://jsonplaceholder.typicode.com/users', {
          method: 'POST',
          body: JSON.stringify(employee),
          headers: { 'Content-type': 'application/json; charset=UTF-8' },
        });
        const data = await response.json();
        this.employees = [...this.employees, data];
      } catch (error) {
        //console.error(error);
      }
    },

    async deleteEmployee(id) {
      try {
        await fetch('https://jsonplaceholder.typicode.com/users/${id}', {
          method: 'DELETE',
        });
        this.employees = this.employees.filter(employee => employee.id !== id);
      } catch (error) {
        //console.error(error);
      }
    },

    async editEmployee(id, updatedEmployee) {
      try {
        const response = await fetch('https://jsonplaceholder.typicode.com/users/${id}', {
          method: 'PUT',
          body: JSON.stringify(updatedEmployee),
          headers: { 'Content-type': 'application/json; charset=UTF-8' },
        });
        const data = await response.json();
        this.employees = this.employees.map(employee => (employee.id === id ? data : employee));
      } catch (error) {
        //console.error(error);
      }
    }
  }
}
</script>

<style>
  button {
    background: #009435;
    border: 1px solid #009435;
  }

  .small-container {
    max-width: 680px;
  }
</style>
