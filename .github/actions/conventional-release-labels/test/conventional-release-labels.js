const { beforeEach, describe, it, afterEach } = require('mocha')
const api = require('../index.js')
const core = require('@actions/core')
const fs = require('fs')
const sinon = require('sinon')
const yaml = require('js-yaml')

const sandbox = sinon.createSandbox()
process.env.GITHUB_EVENT_PATH = process.env.GITHUB_EVENT_PATH || ''

const metadata = yaml.load(fs.readFileSync('./action.yml', 'utf8'))

describe('conventional-release-labels', () => {
  beforeEach(() => {
    sandbox.replace(core, 'getInput', (key) => {
      return metadata.inputs[key].default
    })
  })
  afterEach(() => {
    sandbox.restore()
  })
  it('handles unconventional commit', async () => {
    const addLabels = sandbox.stub(api, 'addLabels').resolves(undefined)
    sandbox.stub(process.env, 'GITHUB_EVENT_PATH').value('./test/fixtures/unconventional.json')
    await api.main()
    sandbox.assert.notCalled(addLabels)
  })
  it('it adds feature label', async () => {
    const addLabels = sandbox.stub(api, 'addLabels').resolves(undefined)
    const removeLabel = sandbox.stub(api, 'removeLabel').resolves(undefined)
    sandbox.stub(process.env, 'GITHUB_EVENT_PATH').value('./test/fixtures/feature.json')
    await api.main()
    sandbox.assert.calledWith(removeLabel, 'feature', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'fix', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'breaking', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'ignore-for-release', sandbox.match.any)
    sandbox.assert.calledWith(addLabels, ['feature'], sandbox.match.any)
  })
  it('it adds breaking label along with type', async () => {
    const addLabels = sandbox.stub(api, 'addLabels').resolves(undefined)
    const removeLabel = sandbox.stub(api, 'removeLabel').resolves(undefined)
    sandbox.stub(process.env, 'GITHUB_EVENT_PATH').value('./test/fixtures/breaking-fix.json')
    await api.main()
    sandbox.assert.calledWith(removeLabel, 'feature', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'fix', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'breaking', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'ignore-for-release', sandbox.match.any)
    sandbox.assert.calledWith(addLabels, ['breaking', 'fix'], sandbox.match.any)
  })
  it('it applies ignore label to list of ignored types', async () => {
    const addLabels = sandbox.stub(api, 'addLabels').resolves(undefined)
    const removeLabel = sandbox.stub(api, 'removeLabel').resolves(undefined)
    sandbox.stub(process.env, 'GITHUB_EVENT_PATH').value('./test/fixtures/ignored.json')
    await api.main()
    sandbox.assert.calledWith(removeLabel, 'feature', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'fix', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'breaking', sandbox.match.any)
    sandbox.assert.calledWith(removeLabel, 'ignore-for-release', sandbox.match.any)
    sandbox.assert.calledWith(addLabels, ['ignore-for-release'], sandbox.match.any)
  })
})
