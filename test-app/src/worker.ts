import { NativeConnection, Worker } from '@temporalio/worker';
import * as activities from './activities';

async function run() {
  const connection = await NativeConnection.connect({
    address: 'temporal-frontend.temporal.svc.cluster.local:7233',
    // TLS and gRPC metadata configuration goes here.
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
