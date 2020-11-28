function [t,Accuracy,Precision,Recall,F1score] = evaluate(x1,x2,n)
    % -------------------------------------------------------
    % Usage:
    % [t,Accuracy,Precision,Recall,F1score] = evaluate(x1,x2,n)
    % -------------------------------------------------------
    % inputs:
    %   x1 -- 1-D array with arbitrary length (positive data)
    %   x2 -- 1-D array with arbitrary length (negative data)
    %   n  -- Divide x1 and x2 into n pieces
    % -------------------------------------------------------
    % outputs:
    %   t         -- X-axis of threshold
    %	Accuracy  -- Accuracy  of positive data
    %	Precision -- Precision of positive data
    %   Recall    -- Recall  of positive data
    %   F1score   -- F1score of positive data
    % -------------------------------------------------------

    len1 = length(x1);
    len2 = length(x2);
    Xmin = min([min(x1),min(x2)]);  % minimum of {x1,x2}
    Xmax = max([max(x1),max(x2)]);  % maximun of {x1,x2}

    dx   = (Xmax - Xmin)/(n-1);     % increase of threshold
    t    = Xmin:dx:Xmax;            % threshold

    d1   = zeros(n-1,1);            % distribution of x1
    d2   = zeros(n-1,1);            % distribution of x2

    TP   = zeros(size(t));          % True  Positive
    TN   = zeros(size(t));          % True  Negative
    FP   = zeros(size(t));          % False Positive
    FN   = zeros(size(t));          % False Negative

    % -------------------------------
    % calulate TP FN TN FP
    for i=1:n
        for j=1:len1
            if x1(j)>t(i)
                TP(i) = TP(i) + 1;
            end
        end
        FN(i) = len1 - TP(i);
        for j=1:len2
            if x2(j)<t(i)
                TN(i) = TN(i) + 1;
            end
        end
        FP(i) = len2 - TN(i);
    end

    % -------------------------------------
    % calculate the distribution of x1 & x2
    for i=1:n-1
        for j=1:len1
            if x1(j)>=t(i) && x1(j)<t(i+1)
                d1(i) = d1(i) + 1;
            end
        end
        d1(i) = d1(i)/len1;

        for j=1:len2
            if x2(j)>=t(i) && x2(j)<t(i+1)
                d2(i) = d2(i) + 1;
            end
        end
        d2(i) = d2(i)/len2;
    end

    % -------------------------------
    % calculate basic indicators
    Accuracy  = (TP + TN)./(TP + TN + FP + FN);
    Precision = TP ./ (TP + FP);
    Recall    = TP ./ (TP + FN);
    F1score   = 2 * Precision .* Recall ./ (Precision + Recall);
        
    TP      = TP / len1;        % Recall of x1
    TN      = TN / len2;        % Recall of x2
    [~,idx] = min(abs(TP -TN)); % eer point
    color1  = [1.0 0.6 0.1];
    color2  = [0.2 0.5 0.7];
    
    % -------------------------------------
    % distribution of positive and negative
    figure
    subplot(2,2,1)
    area(t(1:end-1),d1,'FaceColor',color1,'EdgeColor',color1,'FaceAlpha',1.0,'LineStyle','none');hold on;
    area(t(1:end-1),d2,'FaceColor',color2,'EdgeColor',color2,'FaceAlpha',0.8,'LineStyle','none');
    xlabel('Threshold','fontsize',12);
    ylabel('PDF','fontsize',12);
    legend({'\fontsize{12} positive','\fontsize{12} negative'},'location','best');legend('boxoff');
    
    % -------------------------------
    % Recall vs threshold
    subplot(2,2,2)
    plot(t,TP,'color',color1,'linewidth',2);hold on;
    plot(t,TN,'color',color2,'linewidth',2);axis tight;
    xlabel('Threshold','fontsize',12);
    ylabel('Recall','fontsize',12);
    legend({'\fontsize{12} positive','\fontsize{12} negative'},'location','best');legend('boxoff');
    plot(t(idx),TP(idx)/2+TN(idx)/2,'o','Markersize',6,'MarkerFaceColor','k','color','k');
    text(t(idx),TP(idx)*0.6,['[ ' num2str(t(idx),3) ', ' num2str(TP(idx),3) ' ] '],'fontsize',12);
    
    % -------------------------------
    % alarm rate & miss rate vs threshold
    subplot(2,2,3)
    plot(1-TN,1-TP,'linewidth',2);hold on;
    xlabel('Negative False Alarm Rate','fontsize',12);
    ylabel('Positive Miss Rate','fontsize',12);
    legend({'\fontsize{12} false rate'},'location','best');legend('boxoff');
    plot(1-TP(idx),1-TN(idx),'o','Markersize',6,'MarkerFaceColor','k','color','k');
    text( (1-TP(idx))*1.2,(1-TN(idx))*1.2, [' EER: ' num2str(1-TN(idx),2)],'fontsize',13);
    
    % -------------------------------
    % calculate basic indicators
    subplot(2,2,4)
    plot(t,Accuracy,'linewidth',2);hold on;
    plot(t,Precision,'linewidth',2);hold on;
    plot(t,Recall,'linewidth',2);hold on;
    plot(t,F1score,'linewidth',2);axis tight;
    xlabel('Threshold');
    ylabel('Probability','fontsize',12);
    title('positive data','fontsize',13)
    legend('accuracy','precision','recall','F1score');legend('boxoff');

end
