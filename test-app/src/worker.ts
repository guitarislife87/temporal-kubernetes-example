import { NativeConnection, Worker } from '@temporalio/worker';
import * as activities from './activities';

async function run() {
  const connection = await NativeConnection.connect({
    address: process.env.TEMPORAL_HOST_URL ?? 'http://localhost:7233',
  });

  const worker = await Worker.create({
    connection,
    workflowsPath: require.resolve('./workflows'),
    activities,
    taskQueue: 'activities-examples',
  });

  await worker.run();
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
