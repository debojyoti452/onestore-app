import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onestore_wallet_app/src/screens/card_screen/components/empty_view.dart';
import 'package:onestore_wallet_app/src/screens/card_screen/cubit/card_list_cubit.dart';
import 'package:onestore_wallet_app/src/utils/constants/app_constants.dart';

import '../../utils/global/secure_state_wrapper.dart';
import '../../utils/themes/color_constants.dart';
import '../add_card/add_card_screen.dart';
import 'components/credit_card_widget.dart';

class CardListScreen extends StatefulWidget {
  static const id = 'CARD_LIST_SCREEN';

  const CardListScreen({Key? key}) : super(key: key);

  @override
  _CardListScreenState createState() =>
      _CardListScreenState();
}

class _CardListScreenState
    extends SecureStateWrapper<CardListScreen> {
  double topContainer = 0;
  late CardListCubit _cubit;

  @override
  void onInit() {
    _cubit = context.read<CardListCubit>();
    _cubit.initialize();
  }

  @override
  Widget onBuild(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.GREY,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, AddCardScreen.id);
        },
        mini: true,
        backgroundColor: ColorConstants.BLACK,
        child: Icon(
          Icons.add,
          size: 30.w,
          color: ColorConstants.WHITE,
        ),
        tooltip: 'Add new card',
      ),
      appBar: AppBar(
        backgroundColor: ColorConstants.WHITE,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: ColorConstants.BLACK,
          ),
        ),
        actions: [
          /// refresh button
          IconButton(
            onPressed: () {
              _cubit.getCardList();
            },
            tooltip: 'Refresh to get latest cards',
            icon: const Icon(
              Icons.refresh,
              color: ColorConstants.BLACK,
            ),
          ),
        ],
      ),
      body: BlocConsumer<CardListCubit, CardListState>(
        bloc: _cubit,
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Container(
              margin: EdgeInsets.only(bottom: 40.h),
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: ColorConstants.WHITE,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: state.cardList.isEmpty
                  ? const EmptyView()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                state.cardList.length,
                            scrollDirection: Axis.vertical,
                            physics:
                                const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index ==
                                  state.cardList.length) {
                                return SizedBox(
                                  height: 30.h,
                                );
                              }
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  _cubit.clearCard(
                                    id: state
                                        .cardList[index]
                                        .id!,
                                  );
                                },
                                direction: DismissDirection
                                    .horizontal,
                                child: Align(
                                  heightFactor: 0.9,
                                  alignment:
                                      Alignment.topCenter,
                                  child: CreditCardWidget(
                                    index: index,
                                    card: state
                                        .cardList[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  void onDestroy() {}

  @override
  void onDispose() {}

  @override
  void onPause() {}

  @override
  void onResume() {
    _cubit.getCardList();
  }

  @override
  void onStop() {}
}
