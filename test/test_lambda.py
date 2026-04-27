import unittest
import json
import os
from subprocess import check_call, check_output


def get_plan_json(*extra_args):
    """Run terraform plan and return the parsed JSON plan."""
    check_call(
        ['terraform', '-chdir=test/infra', 'plan',
         '-input=false', '-no-color', '-out=tfplan']
        + list(extra_args)
    )
    raw = check_output(
        ['terraform', '-chdir=test/infra', 'show', '-json', 'tfplan']
    ).decode('utf-8')
    os.remove('test/infra/tfplan')
    return json.loads(raw)


def get_resource_changes(plan_json):
    """Return a dict of address -> resource_change from the plan."""
    return {
        rc['address']: rc
        for rc in plan_json.get('resource_changes', [])
    }


class TestLambdaCron(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        check_call(['terraform', '-chdir=test/infra', 'init', '-input=false'])

    def test_all_resources_to_be_created(self):
        plan = get_plan_json('-target=module.lambda')
        resources = get_resource_changes(plan)
        creates = [
            addr for addr, rc in resources.items()
            if 'create' in rc['change']['actions']
        ]
        self.assertEqual(len(creates), 7)

    def test_create_lambda(self):
        plan = get_plan_json('-target=module.lambda')
        resources = get_resource_changes(plan)

        values = resources[
            'module.lambda.aws_lambda_function.lambda_function'
        ]['change']['after']

        self.assertEqual(values['function_name'], 'check_lambda_function')
        self.assertEqual(values['handler'], 'some_handler')
        self.assertEqual(values['runtime'], 'python2.7')
        self.assertEqual(values['s3_bucket'], 'cdflow-lambda-releases')
        self.assertEqual(values['s3_key'], 's3key.zip')
        self.assertEqual(values['timeout'], 3)
        self.assertEqual(values['memory_size'], 128)

    def test_create_lambda_in_vpc(self):
        plan = get_plan_json(
            '-target=module.lambda',
            '-var', 'subnet_ids=["1","2","3"]',
            '-var', 'security_group_ids=["4"]',
        )
        resources = get_resource_changes(plan)

        values = resources[
            'module.lambda.aws_lambda_function.lambda_function'
        ]['change']['after']

        vpc_config = values['vpc_config']
        self.assertEqual(len(vpc_config), 1)
        self.assertEqual(sorted(vpc_config[0]['subnet_ids']), ['1', '2', '3'])
        self.assertEqual(vpc_config[0]['security_group_ids'], ['4'])

    def test_create_lambda_with_tags(self):
        plan = get_plan_json(
            '-target=module.lambda',
            '-var', 'tags={"component":"test-component","env":"test"}',
        )
        resources = get_resource_changes(plan)

        values = resources[
            'module.lambda.aws_lambda_function.lambda_function'
        ]['change']['after']

        self.assertEqual(values['tags'], {
            'component': 'test-component',
            'env': 'test',
        })

    def test_lambda_in_vpc_gets_correct_execution_role(self):
        plan = get_plan_json(
            '-target=module.lambda',
            '-var', 'subnet_ids=["1","2","3"]',
            '-var', 'security_group_ids=["4"]',
        )
        resources = get_resource_changes(plan)

        vpc_perm = resources.get(
            'module.lambda.aws_iam_role_policy_attachment.vpc_permissions[0]'
        )
        self.assertIsNotNone(vpc_perm)
        self.assertEqual(
            vpc_perm['change']['after']['policy_arn'],
            'arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole',
        )

    def test_cloudwatch_event_rule_created(self):
        plan = get_plan_json('-target=module.lambda')
        resources = get_resource_changes(plan)

        rule = resources[
            'module.lambda.aws_cloudwatch_event_rule.cron_schedule'
        ]['change']['after']
        self.assertEqual(rule['name'], 'check_lambda_function-cron_schedule')
        self.assertEqual(rule['schedule_expression'], 'rate(5 minutes)')
        self.assertEqual(
            rule['description'],
            'This event will run according to a schedule for Lambda check_lambda_function',
        )
        self.assertTrue(rule['is_enabled'])

        target = resources[
            'module.lambda.aws_cloudwatch_event_target.event_target'
        ]['change']['after']
        self.assertEqual(target['rule'], 'check_lambda_function-cron_schedule')

    def test_cloudwatch_event_rule_created_shorten_name(self):
        plan = get_plan_json('-target=module.lambda_long_name')
        resources = get_resource_changes(plan)

        rule = resources[
            'module.lambda_long_name.aws_cloudwatch_event_rule.cron_schedule'
        ]['change']['after']
        self.assertEqual(
            rule['name'],
            'check_lambda_function_with_a_really_long_name_should_be_truncate',
        )
        self.assertEqual(rule['schedule_expression'], 'rate(5 minutes)')


if __name__ == '__main__':
    unittest.main()
