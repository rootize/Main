
function dst=fastMatchTemplate(srca, srcb, maxlevel)   
% srca      The reference image
% srcb      The template image
% dst       Template matching result
% maxlevel  Number of levels


 %std::vector<cv::Mat> refs, tpls, results;

   
     refs=buildPyramid(srca, maxlevel);
     tpls=buildPyramid(srcb, maxlevel);

  %  cv::Mat ref, tpl, res;

  
    for  level = maxlevel:-1: 1
    
        ref = refs{level};
        tpl = tpls{level};
       % res = cv::Mat::zeros(ref.size() + cv::Size(1,1) - tpl.size(), CV_32FC1);

        if (level == maxlevel)
        
         %   // On the smallest level, just perform regular template matching
         %   cv::matchTemplate(ref, tpl, res, CV_TM_CCORR_NORMED);
          res=template_matching(tpl,ref); 
        else
        
%             // On the next layers, template matching is performed on pre-defined 
%             // ROI areas.  We define the ROI using the template matching result 
%             // from the previous layer.

            cv::Mat mask;
            cv::pyrUp(results.back(), mask);

            cv::Mat mask8u;
            mask.convertTo(mask8u, CV_8U);

            // Find matches from previous layer
            std::vector<std::vector<cv::Point> > contours;
            cv::findContours(mask8u, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);

            // Use the contours to define region of interest and 
            // perform template matching on the areas
            for (int i = 0; i < contours.size(); i++)
            {
                cv::Rect r = cv::boundingRect(contours[i]);
                cv::matchTemplate(
                    ref(r + (tpl.size() - cv::Size(1,1))), 
                    tpl, 
                    res(r), 
                    CV_TM_CCORR_NORMED
                );
            }
        }

        // Only keep good matches
        cv::threshold(res, res, 0.94, 1., CV_THRESH_TOZERO);
        results.push_back(res);
    }

    res.copyTo(dst);
            end
        end
    end
end

%MainFunction
fastMatchTemplate(ref_gray, tpl_gray, dst, 2);

    while (true)
    {
        double minval, maxval;
        cv::Point minloc, maxloc;
        cv::minMaxLoc(dst, &minval, &maxval, &minloc, &maxloc);

        if (maxval >= 0.9)
        {
            cv::rectangle(
                ref, maxloc, 
                cv::Point(maxloc.x + tpl.cols, maxloc.y + tpl.rows), 
                CV_RGB(0,255,0), 2
            );
            cv::floodFill(
                dst, maxloc, 
                cv::Scalar(0), 0, 
                cv::Scalar(.1), 
                cv::Scalar(1.)
            );
        }
        else
            break;
    }