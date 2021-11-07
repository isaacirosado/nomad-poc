#!/usr/bin/env node
/*
Very crude app showing how we can use the same Terraform template, and given some inputs,
Inputs which we should probably put in Vaul so both the app and the provisioning system can read them,
Connects to Nomad's API and creates a new deployment
*/

const fs = require('fs')
const Hostel = require('@chatsight/hostel')

async function main() {
  var nomadAPI = new Hostel({
    connection: {
      hostname: "10.106.0.6",
      port: "4646",
      sslEnabled: false,
      ignoreSecretTLSWarning: true,
      ignoreTLSWarning: true
    },
    timeouts: {
      request: 20000
    }
  })
  await nomadAPI.initialize()

  var data = await fs.readFileSync("../../modules/docker-deployment/template.nomad","utf8").toString()
  var template = data.replace(/\${name}/g, "cli")
		.replace(/\${region}/g, "lon1")
		.replace(/\${domain}/g, "rosado.live")
		.replace(/\${dbhost}/g, "private-isaaclivedb-do-user-10124522-0.b.db.ondigitalocean.com")
		.replace(/\${dbport}/g, "25060")
		.replace(/\${dbpswd}/g, "")
		.replace(/\${dbuser}/g, "doadmin")
		.replace(/\${dbname}/g, "clitest")

  await nomadAPI.jobs.parse({
    JobHCL: template,
    Canonicalize: true
  }).then(async jsonObj => {
    console.log(jsonObj[1])
    await nomadAPI.jobs.create({
      Job: jsonObj[1]
    }).then(l => {
      console.log(l)
    })
  })
}
main()
