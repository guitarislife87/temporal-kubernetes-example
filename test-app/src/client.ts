import { Connection, Client } from '@temporalio/client';
import { asyncActivityWorkflow, httpWorkflow } from './workflows';

async function run(): Promise<void> {
  const connection = await Connection.connect({
    address: process.env.TEMPORAL_HOST_URL ?? 'http://localhost:7233',
  });

  const client = new Client({ connection });

  let result = await client.workflow.execute(httpWorkflow, {
    taskQueue: 'activities-examples',
    workflowId: 'activities-examples',
  });
  console.log(result); // 'The answer is 42'

  result = await client.workflow.execute(asyncActivityWorkflow, {
    taskQueue: 'activities-examples',
    workflowId: 'activities-examples',
  });
  console.log(result);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
