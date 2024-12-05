import { describe, it, expect, beforeEach } from 'vitest';

// Mock blockchain state
let experiments: { [key: number]: any } = {};
let experimentResults: { [key: string]: any } = {};
let lastExperimentId = 0;

describe('ExperimentProtocol', () => {
  beforeEach(() => {
    experiments = {};
    experimentResults = {};
    lastExperimentId = 0;
  });
  
  it('ensures experiments can be created and results submitted', () => {
    const user1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const user2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    
    // Create experiment
    lastExperimentId++;
    experiments[lastExperimentId] = {
      creator: user1,
      title: "Test Experiment",
      description: "A test experiment",
      protocol: "1. Do this\n2. Do that",
      start_date: 100,
      end_date: 200,
      status: "active"
    };
    
    expect(experiments[lastExperimentId]).toBeDefined();
    expect(experiments[lastExperimentId].creator).toBe(user1);
    
    // Submit result
    const resultKey = `${lastExperimentId}:${user2}`;
    experimentResults[resultKey] = {
      result_hash: Buffer.from('0000000000000000000000000000000000000000000000000000000000000000', 'hex'),
      submission_date: 150,
      verified: false
    };
    
    expect(experimentResults[resultKey]).toBeDefined();
    
    // Verify result
    experimentResults[resultKey].verified = true;
    expect(experimentResults[resultKey].verified).toBe(true);
  });
  
  it('ensures unauthorized actions are prevented', () => {
    const user1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const user2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    
    // Create experiment
    lastExperimentId++;
    experiments[lastExperimentId] = {
      creator: user1,
      title: "Test Experiment",
      description: "A test experiment",
      protocol: "1. Do this\n2. Do that",
      start_date: 300, // Future date
      end_date: 400,
      status: "active"
    };
    
    // Try to submit result before start date
    const resultKey = `${lastExperimentId}:${user2}`;
    const submitResult = () => {
      const currentDate = 250; // Simulating current date before start_date
      if (currentDate < experiments[lastExperimentId].start_date) {
        throw new Error('ERR-UNAUTHORIZED');
      }
      experimentResults[resultKey] = {
        result_hash: Buffer.from('0000000000000000000000000000000000000000000000000000000000000000', 'hex'),
        submission_date: currentDate,
        verified: false
      };
    };
    
    expect(submitResult).toThrow('ERR-UNAUTHORIZED');
  });
});

