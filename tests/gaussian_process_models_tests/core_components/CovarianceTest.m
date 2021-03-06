classdef CovarianceTest < matlab.unittest.TestCase
    
    properties
        se
        rq
    end
    
    methods(TestMethodSetup)
        function test_create_covariances(testCase)
            % create test covariances
            
            hyperpriors = Hyperpriors();
            
            name = 'SE';
            is_base = true;
            rnd_code = rand(10,1);
            function_handle = {@isotropic_sqdexp_covariance};
            priors = {
                hyperpriors.gaussian_prior('length_scale'), ...
                hyperpriors.gaussian_prior('output_scale'), ...
                };
            
            % SE kernel
            
            testCase.se = Covariance(name, is_base, rnd_code, ...
                function_handle, priors);
            
            % test Rational Quadratic
            
            name = 'RQ';
            is_base = true;
            rnd_code = rand(10,1);
            function_handle = {@isotropic_rq_covariance};
            
            priors = {
                hyperpriors.gaussian_prior('length_scale'), ...
                hyperpriors.gaussian_prior('output_scale'), ...
                hyperpriors.gaussian_prior('alpha'), ...
                };
            
            testCase.rq = Covariance(name, is_base, rnd_code, ...
                function_handle, priors);
            
        end
        
        function test_mask(testCase)
                        
            % Test masked SE 1
            dimension = 1;
            expected_covariance_name = ['SE_', num2str(dimension)];
            expected_number_of_parameters = 2;
            is_base_kernel = true;
            expected_covariance_function_handle = [];
            expected_mean = [0.1; 0.4];
            
            % create covariance function
            covariance = testCase.se.mask(1);
            
            masked_kernel_1 = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                covariance ...
                );

            % Test masked SE 2
            dimension = 2;
            expected_covariance_name = ['SE_', num2str(dimension)];
            expected_number_of_parameters = 2;
            is_base_kernel = true;
            expected_covariance_function_handle = [];
            expected_mean = [0.1; 0.4];
            
            % create covariance function
            covariance = testCase.se.mask(2);
            
            masked_kernel_2 = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                covariance ...
                );
            
            X = [0 0; 0.5 0.5; 1 1; 10 10; 11 11; 0 10; 10 0];
            kernel_se = feval(@isotropic_sqdexp_covariance, ...
                expected_mean, ...
                X);

            testCase.assertTrue( ...
                kernel_se(1,1) ~= kernel_se(6,1) ...
            )

            testCase.assertTrue( ...
                kernel_se(1,1) ~= kernel_se(7,1) ...
            )
        
            testCase.assertTrue( ...
                masked_kernel_1(1,1) == masked_kernel_1(6,1) ...
            )

            testCase.assertTrue( ...
                masked_kernel_1(4,1) == masked_kernel_1(7,1) ...
            )
       
            testCase.assertTrue( ...
                masked_kernel_2(1,1) == masked_kernel_2(7,1) ...
            )

            testCase.assertTrue( ...
                masked_kernel_2(4,1) == masked_kernel_2(6,1) ...
            )
        
        end
    end
    
    methods (Test)
        function testCovariance(testCase)
            
            % TODO fix this. This is a temporary simple list of tests
            %  -- Change verifys to Asserts
            %  -- Organize tests, modularize and create more complex tests
            %  -- add diagnostic messages for each test
            
            % Test SE covariance
            expected_covariance_name = 'SE';
            expected_number_of_parameters = 2;
            is_base_kernel = true;
            expected_covariance_function_handle = ...
                {@isotropic_sqdexp_covariance};
            expected_mean = [0.1; 0.4];
            
            % create covariance function
            covariance = Covariance.str2covariance(...
                expected_covariance_name, [] ...
                );
            
            kernel_se = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                covariance ...
                );
            
            % Test RQ covariance
            expected_covariance_name = 'RQ';
            expected_number_of_parameters = 3;
            is_base_kernel = true;
            expected_covariance_function_handle = ...
                {@isotropic_rq_covariance};
            expected_mean = [0.1; 0.4; 0.05];
            
            % create covariance function
            covariance = Covariance.str2covariance(...
                expected_covariance_name, [] ...
                );
            
            kernel_rq = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                covariance ...
                );
            
            
            % testing equality
            se = testCase.se;
            rq = testCase.rq;
            
            testCase.assertTrue(se == se)
            testCase.assertTrue(rq == rq)
            
            a = (se + rq) * se;
            b = se * se + se * rq;
            
            testCase.assertTrue(a == se * (se + rq))
            testCase.assertTrue(se * (rq + se) == b)
            testCase.assertTrue(a == b)
            
            testCase.assertFalse(se == rq)
            testCase.assertFalse(a == rq)
            testCase.assertFalse(se == b)
            testCase.assertFalse(se + a == se)
            
            % testing addition
            
            se_plus_rq = se + rq;
            
            expected_covariance_name = '(SE+RQ)';
            expected_number_of_parameters = 5;
            is_base_kernel = false;
            expected_covariance_function_handle = [];
            expected_mean = [0.1; 0.4; 0.1; 0.4; 0.05];
            
            kernel_se_plus_rq = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                se_plus_rq ...
                );
            
            
            expected_K = kernel_se + kernel_rq;
            testCase.assertEqual(expected_K, kernel_se_plus_rq)
            
            % test multiplication
            
            se_times_rq = se * rq;
            
            expected_covariance_name = '(SE*RQ)';
            expected_number_of_parameters = 5;
            is_base_kernel = false;
            expected_covariance_function_handle = [];
            expected_mean = [0.1; 0.4; 0.1; 0.4; 0.05];
            
            kernel_se_times_rq = CovarianceTest.test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                se_times_rq ...
                );
            
            
            expected_K = kernel_se .* kernel_rq;
            testCase.assertEqual(expected_K, kernel_se_times_rq)
        end
        
        function test_str2covariance(testCase)
            
            expected_covariance_names = {...
                'SE', 'M1', 'RQ', 'LIN'
                };
            expected_number_of_parameters = {...
                2, ...
                2, ...
                3, ...
                1 ...
                };
            expected_covariance_function_handle = {...
                {@isotropic_sqdexp_covariance}, ...
                {@isotropic_matern_covariance12}, ...
                {@isotropic_rq_covariance} ...
                {@linear_covariance}, ...                
                };
            expected_mean = {
                [0.1; 0.4], ...
                [0.1; 0.4], ...
                [0.1; 0.4; 0.05] ...
                [0.4], ...
                };
            
            is_base_kernel = true;
            
            for i = 1:numel(expected_covariance_names)
                                
                covariance = Covariance.str2covariance(...
                    expected_covariance_names{i}, [] ...
                    );
                
                kernel{i} = CovarianceTest.test_covariance(testCase, ...
                    expected_covariance_names{i}, ...
                    expected_number_of_parameters{i}, ...
                    is_base_kernel, ...
                    expected_covariance_function_handle{i}, ...
                    expected_mean{i}, ...
                    covariance ...
                    );
            end
        end
    end
    
    methods (Static)
        function kernel = test_covariance(testCase, ...
                expected_covariance_name, ...
                expected_number_of_parameters, ...
                is_base_kernel, ...
                expected_covariance_function_handle, ...
                expected_mean, ...
                covariance ...
                )
            
            tolerance = 0.01;
            total_samples = 50000;
            X = [0 0; 0.5 0.5; 1 1; 10 10; 11 11; 0 10; 10 0];
            
            diagnostic = 'Wrong covariance name';
            testCase.assertEqual(expected_covariance_name, ...
                covariance.name, diagnostic)
            
            diagnostic = sprintf('%s %s', 'Wrong number of parameters', ...
                covariance.name');
            computed_number_of_parameters = ...
                eval(feval(covariance.function_handle{:}));
            testCase.assertEqual(expected_number_of_parameters, ...
                computed_number_of_parameters, ...
                diagnostic)
            
            diagnostic = 'Wrong is base kernel';
            testCase.assertEqual(is_base_kernel, ...
                covariance.is_base_kernel(), ...
                diagnostic ...
                );
            
            if ~isempty(expected_covariance_function_handle)
                diagnostic = 'Wrong function handle';
                testCase.assertEqual(expected_covariance_function_handle{:}, ...
                    covariance.function_handle{:}, ...
                    diagnostic ...
                    );
            end
            
            hyperparameters_samples = ...
                zeros(expected_number_of_parameters, total_samples);
            
            for i = 1:total_samples
                hyperparameters_samples(:,i) = ...
                    covariance.get_hyperparameters_sample();
            end
            
            hyperparameters_mean = ...
                exp(mean(hyperparameters_samples, 2));
            
            difference = abs(hyperparameters_mean - expected_mean);
            within_tolerance = all(difference < tolerance);
            
            message = 'Expected avg of hyperparameters samples could be different.\nCheck the sum of difference %s. \nCovariance:%s';
            diagnostic = sprintf(message, mat2str(sum(difference)), covariance.name);
            testCase.verifyTrue(within_tolerance, diagnostic)
            
            
            % return created kernel for latter testing
            kernel = ...
                feval(covariance.function_handle{:}, expected_mean, X);
            
            if ~isempty(expected_covariance_function_handle)                
                
                expected_kernel = ...
                    feval(expected_covariance_function_handle{:}, ...
                    expected_mean, ...
                    X);
                diagnostic = 'Wrong matrix computations';
                testCase.assertEqual(expected_kernel, ...
                    kernel, ...
                    diagnostic ...
                    );                
            end
            
        end
    end
    
end