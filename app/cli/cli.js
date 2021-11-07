#!/usr/bin/env node
/*
Very crude app showing how we can use the same Terraform template, and given some inputs,
Inputs which we should probably put in Vault so both the app and the provisioning system can read them,
Connects to Digital Ocean's API to create a database and then to Nomad's API to deploy the app
*/

const yargs = require('yargs')
const fs = require('fs')
const Hostel = require('@chatsight/hostel')
const {createApiClient} = require('dots-wrapper')

async function main() {
  var argv = yargs(process.argv.slice(2))
    .usage('Usage: $0 -n [deployment name]')
    .demandOption(['n'])
    .argv

  const dbclustername = 'private-isaaclivedb-do-user-10124522-0.b.db.ondigitalocean.com'
  const dbclusterid = 'cecb3645-f582-4b37-bfb8-7cf198c87cf7'
  const dbuser = 'doadmin'
  const dbclusterport = '25060'

  const nomadAPI = new Hostel({
    connection: {
      hostname: '10.106.0.6',
      port: '4646',
      sslEnabled: false,
      ignoreSecretTLSWarning: true,
      ignoreTLSWarning: true
    },
    timeouts: {
      request: 20000
    }
  })
  await nomadAPI.initialize()

  const digitaloceanAPI = createApiClient({token: process.env.TF_VAR_do_token})

  // Create/re-use database
  try {
    await digitaloceanAPI.database.createDatabaseClusterDb({
      database_cluster_id: dbclusterid,
      db_name: argv.n
    })
  } catch (error) {
    if (! (error.response.data && error.response.data.message == 'database name is not available')) {
      console.log(error);
      return
    }
  }

  // Get database password
  const {data:{user}} = await digitaloceanAPI.database.getDatabaseClusterUser({
    database_cluster_id: dbclusterid,
    user_name: dbuser
  })
  const dbpswd = user.password

  // Re-use Terraform template to deploy
  var template_raw = await fs.readFileSync(__dirname + '/../../modules/docker-deployment/template.nomad','utf8').toString()
  var template = template_raw.replace(/\${name}/g, argv.n)
		.replace(/\${region}/g, 'lon1')
		.replace(/\${domain}/g, 'rosado.live')
		.replace(/\${dbhost}/g, dbclustername)
		.replace(/\${dbport}/g, dbclusterport)
		.replace(/\${dbpswd}/g, dbpswd)
		.replace(/\${user}/g, dbuser)
		.replace(/\${dbname}/g, argv.n)

  await nomadAPI.jobs.parse({
    JobHCL: template,
    Canonicalize: true
  }).then(async jsonObj => {
    await nomadAPI.jobs.create({
      Job: jsonObj[1]
    }).then(l => {
      console.log('It is aliiiiiiiive!')
    })
  })
}
main()
